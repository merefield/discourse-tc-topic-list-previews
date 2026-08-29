import { module, test } from "qunit";
import { featuredTopicsRequest } from "../../../discourse/lib/featured-topics-filter";

module("Unit | Lib | featured-topics-filter", function () {
  test("builds a tag topic-list request", function (assert) {
    assert.deepEqual(
      featuredTopicsRequest("tag", "featured|editors"),
      { filter: "tag/featured|editors" },
      "the existing tag and tag-intersection route is preserved"
    );
  });

  test("builds a category topic-list request", function (assert) {
    assert.deepEqual(
      featuredTopicsRequest("category", "fashion"),
      { filter: "latest", params: { category: "fashion" } },
      "the category slug is sent as a latest-list filter"
    );
  });
});
