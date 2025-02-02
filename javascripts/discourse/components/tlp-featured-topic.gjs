import { inject as service } from "@ember/service";
import Component from "@glimmer/component";
import PreviewsThumbnail from "./previews-thumbnail";
import avatar from "discourse/helpers/avatar";

export default class TlpFeaturedTopicComponent extends Component {
  @service currentUser;

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

  <template>
    <a href="{{this.href}}" class="tlp-featured-topic {{this.featuredTag}}">
      <div class="featured-details">
        <PreviewsThumbnail
          @url={{this.href}}
          @thumbnails={{@topic.thumbnails}}
          @featured={{true}}
        />
        <div class="content">
          <div class="title">
            {{this.args.topic.title}}
          </div>
          {{#if this.featuredExcerpt}}
            <div class="excerpt">
              {{{this.featuredExcerpt}}}
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
