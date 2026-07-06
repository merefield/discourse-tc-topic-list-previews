import Component from "@glimmer/component";
import { service } from "@ember/service";
import PreviewsThumbnail from "../../components/previews-thumbnail";

export default class SearchThumbnail extends Component {
  @service siteSettings;

  <template>
    {{#if this.siteSettings.topic_list_search_previews_enabled}}
      <PreviewsThumbnail @topic={{@outletArgs.topic}} @tiles={{true}} />
    {{/if}}
  </template>
}
