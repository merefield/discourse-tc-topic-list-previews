export default {
  setupComponent(attrs, component) {
    component.set("portfolioEnabled", settings.topic_list_portfolio);
    component.set("portfolioIcon", settings.topic_list_portfolio_icons);
  },
};
