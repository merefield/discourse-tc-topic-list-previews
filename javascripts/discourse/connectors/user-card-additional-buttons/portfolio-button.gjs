import Component from "@glimmer/component";
import PortfolioButton from "../../components/portfolio-button";

export default class PortfolioButtonContainer extends Component {
  get portfolioEnabled() {
    return settings.topic_list_portfolio;
  }

  <template>
    {{#if this.portfolioEnabled}}
      <PortfolioButton @user={{@user}} />
    {{/if}}
  </template>
}
