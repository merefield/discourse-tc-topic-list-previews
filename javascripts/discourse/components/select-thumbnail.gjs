import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action, computed } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DToggleSwitch from "discourse/components/d-toggle-switch";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import TlpThumbnailSelectorModalComponent from "../components/modal/tlp-thumbnail-selector";

export default class SelectThumbnailComponent extends Component {
  @service modal;

  @action
  showThumbnailSelector() {
    ajax(`/topic-previews/thumbnail-selection.json?topic=${this.args.topic_id}`)
      .then((result) => {
        this.modal.show(TlpThumbnailSelectorModalComponent, {
          model: {
            thumbnails: result.thumbnailselection,
            topic_id: this.args.topic_id,
            topic_title: this.args.topic_title,
            buffered: this.args.buffered,
          },
        });
      })
      .catch((error) => {
        popupAjaxError(error);
      });
  }

  @computed("args.buffered.show_latest_post_excerpt")
  get showLatestPostExcerpt() {
    return this.args.buffered.get("show_latest_post_excerpt") || false;
  }

  @computed("args.buffered.force_latest_post_nav")
  get forceLatestPostNav() {
    return this.args.buffered.get("force_latest_post_nav") || false;
  }

  @action
  updateForceLatestPostNav() {
    this.args.buffered.set(
      "force_latest_post_nav",
      !this.args.buffered.get("force_latest_post_nav")
    );
  }

  @action
  updateShowLatestPostExcerpt() {
    this.args.buffered.set(
      "show_latest_post_excerpt",
      !this.args.buffered.get("show_latest_post_excerpt")
    );
  }

  <template>
    <div class="select-thumbnail">
      <DButton
        id="select-thumbnail-button"
        class="btn-default select-thumbnail"
        @action={{this.showThumbnailSelector}}
        @icon="id-card"
        @label={{themePrefix "tlp.thumbnail_selector.select_preview_button"}}
      />
      {{#if @buffered.user_chosen_thumbnail_url}}
        <br /><img
          src={{@buffered.user_chosen_thumbnail_url}}
          class="select-thumbnail-preview"
        />
      {{/if}}
      <DToggleSwitch
        @label={{themePrefix "tlp.thumbnail_selector.force_latest_post_nav"}}
        @state={{this.forceLatestPostNav}}
        {{on "click" this.updateForceLatestPostNav}}
      />
      <DToggleSwitch
        @label={{themePrefix "tlp.thumbnail_selector.show_latest_post_excerpt"}}
        @state={{this.showLatestPostExcerpt}}
        {{on "click" this.updateShowLatestPostExcerpt}}
      />
    </div>
  </template>
}
