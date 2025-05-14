
import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";


export default class PortfolioButton extends Component {
  @service router;

  @action
  openPortfolio() {
    this.router.transitionTo(
      "userActivity.portfolio",
      this.args.user
    );
  }

  get portfolioIcon() {
    return settings.topic_list_portfolio_icons;
  }

  <template>
    <DButton
      class="btn-primary"
      @icon={{this.portfolioIcon}}
      @action={{this.openPortfolio}}
      @label={{themePrefix "tlp.user_activity_portfolio_title"}}
      />
  </template>
}
