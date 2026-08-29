import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action, computed } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import { service } from "@ember/service";
import { findOrResetCachedTopicList } from "discourse/lib/cached-topic-list";
import { cook } from "discourse/lib/text";
import Category from "discourse/models/category";
import dCategoryBadge from "discourse/ui-kit/helpers/d-category-badge";
import dDiscourseTag from "discourse/ui-kit/helpers/d-discourse-tag";
import { featuredTopicsRequest } from "../lib/featured-topics-filter";
import TlpFeaturedTopic from "./tlp-featured-topic";
import TlpFeaturedTopicsCarousel from "./tlp-featured-topics-carousel";

export default class TlpFeaturedTopicsComponent extends Component {
  @service appEvents;
  @service store;
  @service session;

  @tracked featuredTitle = "";
  @tracked featuredTopics = [];

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
    if (settings.topic_list_featured_images_tag !== "") {
      const { filter, params } = featuredTopicsRequest(
        settings.topic_list_featured_images_filter_type,
        settings.topic_list_featured_images_tag
      );
      findOrResetCachedTopicList(this.session, filter);
      let list = await this.store.findFiltered("topicList", { filter, params });

      if (typeof list !== "undefined") {
        let topics = list.topics ?? list.topic_list?.topics ?? [];

        if (
          this.args.category &&
          settings.topic_list_featured_images_from_current_category_only
        ) {
          topics = topics.filter(
            (topic) => topic.category_id === this.args.category.id
          );
        }

        const reducedTopics = topics
          ? settings.topic_list_featured_images_count === 0
            ? topics
            : topics.slice(0, settings.topic_list_featured_images_count)
          : [];

        if (settings.topic_list_featured_images_order === "created") {
          reducedTopics.sort((a, b) => {
            let keyA = new Date(a.created_at),
              keyB = new Date(b.created_at);
            // Compare the 2 dates
            if (keyA < keyB) {
              return 1;
            }
            if (keyA > keyB) {
              return -1;
            }
            return 0;
          });
        } else if (settings.topic_list_featured_images_order === "random") {
          reducedTopics.sort(() => Math.random() - 0.5);
        }
        this.featuredTopics = reducedTopics;
      }
    }
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
      {{didUpdate this.getFeaturedTopics}}
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
