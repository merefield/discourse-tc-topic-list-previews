import UserAction from "discourse/models/user-action";
import UserTopicListRoute from "discourse/routes/user-topic-list";

export default UserTopicListRoute.extend({
  userActionType: UserAction.TYPES.topics,

  model() {
    let filter_type = settings.topic_list_portfolio_filter_type;
    const filter_parameter = settings.topic_list_portfolio_filter_parameter;

    if (filter_type === "tag") {
      filter_type = "tags";
    }

    return this.store.findFiltered("topicList", {
      filter:
        "topics/created-by/" + this.modelFor("user").get("username_lower"),
      params: { [filter_type]: filter_parameter },
    });
  },
});
