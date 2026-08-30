import Component from "@glimmer/component";
import { service } from "@ember/service";
import { trustHTML } from "@ember/template";
import avatar from "discourse/helpers/avatar";
import concatClass from "discourse/helpers/concat-class";
import PreviewsThumbnail from "./previews-thumbnail";

export default class TlpFeaturedTopicComponent extends Component {
  @service capabilities;
  @service currentUser;

  get featuredUser() {
    return this.args.topic.posters[0].user;
  }

  get featuredUsername() {
    return this.args.topic.posters[0].user.username;
  }

  get featuredExcerpt() {
    return this.featuredExcerptLength > 0 && this.args.topic.excerpt
      ? this.args.topic.excerpt.slice(0, this.featuredExcerptLength)
      : false;
  }

  get featuredExcerptLength() {
    const configuredLength = this.capabilities.viewport.sm
      ? settings.topic_list_featured_excerpt_desktop
      : settings.topic_list_featured_excerpt_mobile;

    return Math.max(0, Number(configuredLength) || 0);
  }

  get featuredTags() {
    if (settings.topic_list_featured_images_filter_type === "category") {
      return [];
    }

    return settings.topic_list_featured_images_tag.split("|");
  }

  get featuredTag() {
    return this.args.topic.tags.filter(
      (tag) => this.featuredTags.indexOf(tag) > -1
    )[0];
  }

  get href() {
    return `/t/${this.args.topic.id}`;
  }

  get detailsPresentation() {
    return this.capabilities.viewport.sm
      ? settings.topic_list_featured_details_desktop
      : settings.topic_list_featured_details_mobile;
  }

  get detailsPositionClass() {
    return this.detailsPresentation === "Under" ? "--under" : "--over";
  }

  get detailsVisibilityClass() {
    return this.detailsPresentation === "Always over" ||
      (!this.capabilities.viewport.sm && this.detailsPresentation === "Over")
      ? "is-always-visible"
      : "";
  }

  get showAttribution() {
    return this.detailsPositionClass === "--over";
  }

  <template>
    <a href={{this.href}} class="tlp-featured-topic {{this.featuredTag}}">
      <div
        class={{concatClass
          "featured-details"
          this.detailsPositionClass
          this.detailsVisibilityClass
        }}
      >
        <div class="featured-details__image">
          <PreviewsThumbnail @topic={{@topic}} />
        </div>
        <div class="content">
          <div class="title">
            {{@topic.title}}
          </div>
          {{#if this.featuredExcerpt}}
            <div class="excerpt">
              {{trustHTML this.featuredExcerpt}}
            </div>
          {{/if}}
          {{#if this.showAttribution}}
            <span class="user">
              {{this.featuredUsername}}
              {{avatar this.featuredUser imageSize="small"}}
            </span>
          {{/if}}
        </div>
      </div>
    </a>
  </template>
}
