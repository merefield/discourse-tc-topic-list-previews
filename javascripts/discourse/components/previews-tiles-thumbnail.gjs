
import concatClass from "discourse/helpers/concat-class";
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action, computed } from "@ember/object";
import { inject as service } from "@ember/service";
import I18n from "I18n";
import PreviewsThumbnail from "./previews-thumbnail";

export default class PreviewsTilesThumbnail extends Component {
  <template>
    <div class="topic-thumbnail">
      <PreviewsThumbnail @thumbnails={{@thumbnails}} @tiles={{true}} />
    </div>
  </template>
}