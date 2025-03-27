import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import BufferedProxy from "ember-buffered-proxy/proxy";
import DModal from "discourse/components/d-modal";
import { i18n } from "discourse-i18n";

export default class TlpThumbnailSelectorComponent extends Component {
  @tracked buffered = BufferedProxy.create({
    content: this.args.model,
  });

  @action
  selectThumbnail(imageUrl, uploadId) {
    this.args.model.buffered.set("user_chosen_thumbnail_url", imageUrl);
    this.args.model.buffered.set("image_upload_id", uploadId);
    this.args.closeModal();
  }

  <template>
    <DModal
      @closeModal={{@closeModal}}
      @flash={{this.flash}}
      class="select-thumbnail"
      @title={{i18n (themePrefix "tlp.thumbnail_selector.title")}}
    >
      <h3>
        {{i18n (themePrefix "tlp.thumbnail_selector.topic_title_prefix")}}
        "{{@model.topic_title}}"
      </h3>

      <span class="select-thumbnail">
        {{#each @model.thumbnails as |thumbnail|}}
          <button
            type="button"
            class="select-thumbnail-options"
            {{on
              "click"
              (fn this.selectThumbnail thumbnail.image_url thumbnail.upload_id)
            }}
          >
            <img src={{thumbnail.image_url}} alt="Thumbnail" />
          </button>
        {{/each}}
      </span>
    </DModal>
  </template>
}
