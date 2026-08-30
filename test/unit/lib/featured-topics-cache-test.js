import { module, test } from "qunit";
import { findCachedFeaturedTopicList } from "../../../discourse/lib/featured-topics-cache";

module("Unit | Lib | featured-topics-cache", function () {
  test("reuses identical requests within a session", async function (assert) {
    const session = {};
    const topicList = { topics: [{ id: 1 }] };
    let requests = 0;
    const store = {
      findFiltered() {
        requests++;
        return Promise.resolve(topicList);
      },
    };
    const args = {
      request: { filter: "tag/featured", params: { per_page: 6 } },
      session,
      store,
      userId: 1,
    };

    const [first, second] = await Promise.all([
      findCachedFeaturedTopicList(args),
      findCachedFeaturedTopicList(args),
    ]);

    assert.strictEqual(first, topicList, "the first caller receives the list");
    assert.strictEqual(
      second,
      topicList,
      "the second caller receives the list"
    );
    assert.strictEqual(requests, 1, "only one store request is made");
  });

  test("keeps request parameters and users in separate cache entries", async function (assert) {
    const session = {};
    let requests = 0;
    const store = {
      findFiltered() {
        requests++;
        return Promise.resolve({ topics: [] });
      },
    };

    await findCachedFeaturedTopicList({
      request: { filter: "tag/featured", params: { per_page: 6 } },
      session,
      store,
      userId: 1,
    });
    await findCachedFeaturedTopicList({
      request: { filter: "tag/featured", params: { per_page: 8 } },
      session,
      store,
      userId: 1,
    });
    await findCachedFeaturedTopicList({
      request: { filter: "tag/featured", params: { per_page: 8 } },
      session,
      store,
      userId: 2,
    });

    assert.strictEqual(requests, 3, "each distinct request context is loaded");
  });

  test("does not cache failed requests", async function (assert) {
    const session = {};
    let requests = 0;
    const store = {
      findFiltered() {
        requests++;
        if (requests === 1) {
          return Promise.reject(new Error("network unavailable"));
        }
        return Promise.resolve({ topics: [] });
      },
    };
    const args = {
      request: { filter: "tag/featured" },
      session,
      store,
    };

    await assert.rejects(
      findCachedFeaturedTopicList(args),
      /network unavailable/,
      "the request failure is passed to the caller"
    );
    await findCachedFeaturedTopicList(args);

    assert.strictEqual(requests, 2, "the failed request is retried");
  });
});
