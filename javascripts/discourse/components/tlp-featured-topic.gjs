import Component from "@glimmer/component";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import avatar from "discourse/helpers/avatar";
import concatClass from "discourse/helpers/concat-class";
import PreviewsThumbnail from "./previews-thumbnail";

export default class TlpFeaturedTopicComponent extends Component {
  @service currentUser;
  @service site;

  get featuredUser() {
    return this.args.topic.posters[0].user;
  }

  get featuredUsername() {
    return this.args.topic.posters[0].user.username;
  }

  get featuredExcerpt() {
    return settings.topic_list_featured_excerpt > 0 && this.args.topic.excerpt
      ? this.args.topic.excerpt.slice(0, settings.topic_list_featured_excerpt)
      : false;
  }

  get featuredTags() {
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

  get alwaysShowDetails() {
    return settings.topic_list_featured_details_always_show === "always" ||
      (this.site.mobileView &&
        settings.topic_list_featured_details_always_show === "mobile device")
      ? "always-show"
      : "";
  }

  <template>
    <a href={{this.href}} class="tlp-featured-topic {{this.featuredTag}}">
      <div class={{concatClass "featured-details" this.alwaysShowDetails}}>
        <PreviewsThumbnail
          @url={{this.href}}
          @thumbnails={{@topic.thumbnails}}
          @featured={{true}}
        />
        <div class="content">
          <div class="title">
            {{@topic.title}}
          </div>
          {{#if this.featuredExcerpt}}
            <div class="excerpt">
              {{htmlSafe this.featuredExcerpt}}
            </div>
          {{/if}}
          <span class="user">
            {{this.featuredUsername}}
            {{avatar this.featuredUser imageSize="small"}}
          </span>
        </div>
      </div>
    </a>
  </template>
}
