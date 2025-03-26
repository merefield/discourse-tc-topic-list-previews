import Component from "@ember/component";
import { action, computed } from "@ember/object";
import BufferedProxy from "ember-buffered-proxy/proxy";

export default Component.extend({
  @computed("model")
  buffered(model) {
    return BufferedProxy.create({
      content: model,
    });
  },

  @action
  selectThumbnail(image_url, image_upload_id) {
    this.set("model.buffered.user_chosen_thumbnail_url", image_url);
    this.set("model.buffered.image_upload_id", image_upload_id);
    this.closeModal();
  },
});
