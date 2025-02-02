import { service } from "@ember/service";
import Component from "@glimmer/component";
import PreviewsMeta from "./footer/previews-meta";
import PreviewsUsers from "./footer/previews-users";
import PreviewsActions from "./footer/previews-actions";

export default class PreviewsFooter extends Component {
  <template>
    <div class="topic-footer">
      <PreviewsMeta @topic={{@topic}} />
      <PreviewsUsers @topic={{@topic}} />
      <PreviewsActions @topic={{@topic}} />
    </div>
  </template>
}
