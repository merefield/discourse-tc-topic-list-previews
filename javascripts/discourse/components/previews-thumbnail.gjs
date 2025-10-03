import Component from "@glimmer/component";
import { service } from "@ember/service";
import concatClass from "discourse/helpers/concat-class";

export default class PreviewsThumbnail extends Component {
  @service currentUser;
  @service topicListPreviews;

  get getDefaultThumbnail() {
    const defaultThumbnail = settings.topic_list_default_thumbnail_fallback;
    return defaultThumbnail ? settings.topic_list_default_thumbnail : false;
  }

  get previewUrl() {
    const preferLowRes =
      this.currentUser !== undefined && this.currentUser !== null
        ? this.currentUser.custom_fields
            .tlp_user_prefs_prefer_low_res_thumbnails
        : false;
    if (this.args.topic.thumbnails) {
      let resLevel = settings.topic_list_thumbnail_resolution_level;
      resLevel = Math.round(
        ((this.args.topic.thumbnails.length - 1) / 6) * resLevel
      );
      if (preferLowRes) {
        resLevel++;
      }
      if (window.devicePixelRatio && resLevel > 0) {
        resLevel--;
      }
      return resLevel <= this.args.topic.thumbnails.length - 1
        ? this.args.topic.thumbnails[resLevel].url
        : this.args.topic.thumbnails[this.args.topic.thumbnails.length - 1].url;
    } else {
      return this.getDefaultThumbnail;
    }
  }

  get isTiles() {
    return this.args.tiles ? "tiles-thumbnail" : "non-tiles-thumbnail";
  }

  get destinationUrl() {
    if (this.args.topic.force_latest_post_nav && this.args.topic.last_post_id) {
      return `/t/${this.args.topic.slug}/${this.args.topic.id}/${this.args.topic.last_post_id}`;
    } else {
      return this.args.topic.url;
    }
  }

  <template>
    {{#if this.previewUrl}}
      <a href={{this.destinationUrl}}>
        <img
          class={{concatClass "thumbnail" this.isTiles}}
          src={{this.previewUrl}}
          loading="lazy"
        />
      </a>
    {{/if}}
  </template>
}
