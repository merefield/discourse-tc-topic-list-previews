import { module, test } from "qunit";
import {
  categoryContainsTopic,
  featuredTopicsPageSize,
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

  test("buffers bounded topic-list requests", function (assert) {
    assert.strictEqual(
      featuredTopicsPageSize(3),
      6,
      "small lists request twice the displayed population"
    );
    assert.strictEqual(
      featuredTopicsPageSize(20),
      30,
      "buffered requests are capped at the server maximum"
    );
    assert.strictEqual(
      featuredTopicsPageSize(0),
      undefined,
      "an unlimited featured list uses the default topic-list page size"
    );
  });

  test("requests created ordering from the server", function (assert) {
    assert.deepEqual(
      featuredTopicsRequest("tag", "featured", {
        count: 4,
        order: "created",
      }),
      {
        filter: "tag/featured",
        params: { per_page: 8, order: "created" },
      },
      "the server limits and orders the result before serialization"
    );
  });

  test("scopes a tag request to the exact current category", function (assert) {
    assert.deepEqual(
      featuredTopicsRequest("tag", "featured", {
        currentCategory: { id: 3 },
        restrictToCurrentCategory: true,
      }),
      {
        filter: "tag/featured",
        params: { no_subcategories: true, category: "3" },
      },
      "category filtering happens in the topic query"
    );
  });

  test("scopes a category source to a descendant current category", function (assert) {
    const featuredCategory = { id: 2 };
    const currentCategory = { id: 3, ancestors: [featuredCategory] };

    assert.deepEqual(
      featuredTopicsRequest("category", "fashion", {
        currentCategory,
        featuredCategory,
        restrictToCurrentCategory: true,
      }),
      {
        filter: "latest",
        params: { no_subcategories: true, category: "3" },
      },
      "the narrower category is sent to the server"
    );
  });

  test("skips unrelated current categories for a category source", function (assert) {
    assert.strictEqual(
      featuredTopicsRequest("category", "fashion", {
        currentCategory: { id: 3 },
        featuredCategory: { id: 2 },
        restrictToCurrentCategory: true,
      }),
      undefined,
      "no request is needed when the category intersection is empty"
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
