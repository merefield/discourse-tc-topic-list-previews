
import concatClass from "discourse/helpers/concat-class";
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action, computed } from "@ember/object";
import { inject as service } from "@ember/service";
import I18n from "I18n";

export default class PreviewsThumbnailComponent extends Component {
  @service currentUser;

  get getDefaultThumbnail() {
    const defaultThumbnail = settings.topic_list_default_thumbnail;
    return defaultThumbnail ? defaultThumbnail : false;
  };


  get previewUrl() {
    const preferLowRes =
      (this.currentUser !== undefined && this.currentUser !== null) ?
        this.currentUser.custom_fields
          .tlp_user_prefs_prefer_low_res_thumbnails
        : false;
    if (this.args.thumbnails) {
      let resLevel = settings.topic_list_thumbnail_resolution_level;
      resLevel = Math.round(((this.args.thumbnails.length - 1) / 6) * resLevel);
      if (preferLowRes) {
        resLevel++;
      }
      if (window.devicePixelRatio && resLevel > 0) {
        resLevel--;
      }
      return resLevel <= this.args.thumbnails.length - 1
        ? this.args.thumbnails[resLevel].url
        : this.args.thumbnails[this.args.thumbnails.length - 1].url;
    } else {
      return this.getDefaultThumbnail;
    }
  };

  <template>
    <div class="topic-thumbnail">
      {{#if this.previewUrl}}
        <img class="thumbnail" src="{{this.previewUrl}}" loading="lazy"/>
      {{/if}}
    </div>
  </template>
}