import Component from "@glimmer/component";
import { LinkTo } from "@ember/routing";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default class UserVotedTopics extends Component {
  get portfolioIcon() {
    return settings.topic_list_portfolio_icons || "images";
  }

  get portfolioEnabled() {
    return settings.topic_list_portfolio;
  }

  <template>
    {{#if this.portfolioEnabled}}
      <li class="user-nav__activity-portfolio">
        <LinkTo @route="userActivity.portfolio">
          {{icon this.portfolioIcon}}
          {{i18n (themePrefix "tlp.user_activity_portfolio_title")}}
        </LinkTo>
      </li>
    {{/if}}
  </template>
}
