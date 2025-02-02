import { service } from "@ember/service";
import Component from "@glimmer/component";
import ItemTopicCell from "discourse/components/topic-list/item/topic-cell";
import PreviewsExcerpt from "./details/previews-excerpt";
import PreviewsFooter from "./details/previews-footer";

export default class PreviewsDetails extends Component {
  <template>
    <div class="topic-details">
      <ItemTopicCell @topic={{@topic}} />
      <PreviewsExcerpt @topic={{@topic}} />
      <PreviewsFooter @topic={{@topic}} />
    </div>
  </template>
}
