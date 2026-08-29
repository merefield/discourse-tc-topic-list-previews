import { module, test } from "qunit";
import {
  categoryContainsTopic,
  featuredTopicsRequest,
} from "../../../discourse/lib/featured-topics-filter";

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

  test("matches a topic in the featured category", function (assert) {
    assert.true(
      categoryContainsTopic({ id: 2 }, { id: 2 }),
      "the direct category matches without requiring ancestors"
    );
  });

  test("matches a topic in a descendant category", function (assert) {
    assert.true(
      categoryContainsTopic(
        { id: 2 },
        { id: 3, ancestors: [{ id: 1 }, { id: 2 }] }
      ),
      "an ancestor matching the featured category is accepted"
    );
  });

  test("does not match an unrelated category without ancestors", function (assert) {
    assert.false(
      categoryContainsTopic({ id: 2 }, { id: 3 }),
      "missing ancestry is handled safely"
    );
  });
});
