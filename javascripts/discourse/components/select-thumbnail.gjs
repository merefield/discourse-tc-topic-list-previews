import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
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
    </div>
  </template>
}
