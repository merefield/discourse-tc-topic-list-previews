import Component from "@glimmer/component";
import { service } from "@ember/service";
import TlpUserPreferences from "../../components/tlp-user-preferences";

export default class UserCustomPreferencesTlpUserPreferences extends Component {
  @service siteSettings;

  <template>
    {{#if this.siteSettings.topic_list_previews_enabled}}
      <TlpUserPreferences @model={{@outletArgs.model}} />
    {{/if}}
  </template>
}
