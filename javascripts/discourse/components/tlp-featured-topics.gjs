import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action, computed } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import { service } from "@ember/service";
import { cook } from "discourse/lib/text";
import Category from "discourse/models/category";
import dCategoryBadge from "discourse/ui-kit/helpers/d-category-badge";
import dDiscourseTag from "discourse/ui-kit/helpers/d-discourse-tag";
import { findCachedFeaturedTopicList } from "../lib/featured-topics-cache";
import { featuredTopicsRequest } from "../lib/featured-topics-filter";
import TlpFeaturedTopic from "./tlp-featured-topic";
import TlpFeaturedTopicsCarousel from "./tlp-featured-topics-carousel";

export default class TlpFeaturedTopicsComponent extends Component {
  @service appEvents;
  @service currentUser;
  @service store;
  @service session;

  @tracked featuredTitle = "";
  @tracked featuredTopics = [];

  featuredTopicsLoadId = 0;

  constructor() {
    super(...arguments);
    this.appEvents.trigger("topic:refresh-timeline-position");

    if (this.showFeaturedTitle) {
      const raw = settings.topic_list_featured_title;
      cook(raw).then((cooked) => (this.featuredTitle = cooked));
    }
  }

  @action
  async getFeaturedTopics() {
    const loadId = ++this.featuredTopicsLoadId;
    const source = settings.topic_list_featured_images_tag.trim();

    if (!this.featuredImagesEnabled || source.length === 0) {
      this.featuredTopics = [];
      return;
    }

    const filterType = settings.topic_list_featured_images_filter_type;
    const featuredCategory =
      filterType === "category" ? Category.findSingleBySlug(source) : undefined;
    const request = featuredTopicsRequest(filterType, source, {
      count: settings.topic_list_featured_images_count,
      currentCategory: this.args.category,
      featuredCategory,
      order: settings.topic_list_featured_images_order,
      restrictToCurrentCategory:
        Boolean(this.args.category) &&
        settings.topic_list_featured_images_from_current_category_only,
    });

    if (!request) {
      this.featuredTopics = [];
      return;
    }

    const list = await findCachedFeaturedTopicList({
      request,
      session: this.session,
      store: this.store,
      userId: this.currentUser?.id,
    });

    if (loadId !== this.featuredTopicsLoadId) {
      return;
    }

    if (typeof list !== "undefined") {
      let topics = [...(list.topics ?? list.topic_list?.topics ?? [])].filter(
        (topic) => this.hasUsableImage(topic)
      );

      if (settings.topic_list_featured_images_order === "random") {
        topics = this.shuffle(topics);
      }

      const count = Math.max(
        0,
        Number(settings.topic_list_featured_images_count) || 0
      );
      this.featuredTopics = count > 0 ? topics.slice(0, count) : topics;
    }
  }

  get featuredImagesEnabled() {
    return this.args.category
      ? settings.topic_list_featured_images_category
      : settings.topic_list_featured_images;
  }

  hasUsableImage(topic) {
    return (
      topic.thumbnails?.length > 0 ||
      (settings.topic_list_default_thumbnail_fallback &&
        settings.topic_list_default_thumbnail)
    );
  }

  shuffle(topics) {
    const shuffled = [...topics];

    for (let index = shuffled.length - 1; index > 0; index--) {
      const swapIndex = Math.floor(Math.random() * (index + 1));
      [shuffled[index], shuffled[swapIndex]] = [
        shuffled[swapIndex],
        shuffled[index],
      ];
    }

    return shuffled;
  }

  @computed("featuredTopics")
  get showFeatured() {
    return (
      ((settings.topic_list_featured_images && this.args.category == null) ||
        (settings.topic_list_featured_images_category &&
          this.args.category !== null)) &&
      this.featuredTopics.length > 0
    );
  }

  @computed
  get showFeaturedTitle() {
    return settings.topic_list_featured_title;
  }

  @computed
  get featuredTags() {
    if (settings.topic_list_featured_images_filter_type === "category") {
      return [];
    }

    return settings.topic_list_featured_images_tag.split("|");
  }

  @computed
  get featuredCategory() {
    if (settings.topic_list_featured_images_filter_type !== "category") {
      return;
    }

    return Category.findSingleBySlug(settings.topic_list_featured_images_tag);
  }

  @computed
  get showFeaturedSource() {
    return (
      settings.topic_list_featured_images_source_show &&
      (this.featuredTags.length > 0 || this.featuredCategory)
    );
  }

  get carouselView() {
    return settings.topic_list_featured_images_view_type === "Carousel";
  }

  <template>
    <div
      {{didInsert this.getFeaturedTopics}}
      {{didUpdate this.getFeaturedTopics @category.id}}
      class="tlp-featured-topics
        {{if this.showFeatured 'has-topics'}}
        {{if this.carouselView '--carousel'}}"
    >
      {{#if this.showFeatured}}
        {{#if this.showFeaturedTitle}}
          <div class="featured-title">
            {{this.featuredTitle}}
          </div>
        {{/if}}
        {{#if this.carouselView}}
          <TlpFeaturedTopicsCarousel @topics={{this.featuredTopics}} as |topic|>
            <TlpFeaturedTopic @topic={{topic}} />
          </TlpFeaturedTopicsCarousel>
        {{else}}
          <div class="topics">
            {{#each this.featuredTopics as |t|}}
              <TlpFeaturedTopic @topic={{t}} />
            {{/each}}
          </div>
        {{/if}}
        {{#if this.showFeaturedSource}}
          <div class="featured-source">
            {{#if this.featuredCategory}}
              {{dCategoryBadge this.featuredCategory link=true}}
            {{else}}
              {{#each this.featuredTags as |tag|}}
                {{dDiscourseTag tag}}
              {{/each}}
            {{/if}}
          </div>
        {{/if}}
      {{/if}}
    </div>
  </template>
}
