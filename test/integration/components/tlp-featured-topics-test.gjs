import Service from "@ember/service";
import { find, render, settled, waitUntil } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import TlpFeaturedTopics from "../../../discourse/components/tlp-featured-topics";

class DeferredStore extends Service {
  requests = [];

  findFiltered(_type, request) {
    let resolve;
    const promise = new Promise((resolver) => {
      resolve = resolver;
    });

    this.requests.push({ request, resolve });

    return promise;
  }
}

function topic(id, title) {
  return {
    id,
    title,
    excerpt: "",
    posters: [
      {
        user: {
          avatar_template: "/letter_avatar_proxy/v4/letter/a/13edae/{size}.png",
          username: "alice",
        },
      },
    ],
    tags: [],
    thumbnails: [{ url: "/images/avatar.png" }],
  };
}

module("Integration | Component | TlpFeaturedTopics", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.currentUser.set("custom_fields", {});
    this.originalSettings = {
      categoryEnabled: settings.topic_list_featured_images_category,
      count: settings.topic_list_featured_images_count,
      filterType: settings.topic_list_featured_images_filter_type,
      order: settings.topic_list_featured_images_order,
      restrictToCategory:
        settings.topic_list_featured_images_from_current_category_only,
      showSource: settings.topic_list_featured_images_source_show,
      source: settings.topic_list_featured_images_tag,
      viewType: settings.topic_list_featured_images_view_type,
    };

    settings.topic_list_featured_images_category = true;
    settings.topic_list_featured_images_count = 3;
    settings.topic_list_featured_images_filter_type = "tag";
    settings.topic_list_featured_images_from_current_category_only = true;
    settings.topic_list_featured_images_order = "latest";
    settings.topic_list_featured_images_source_show = false;
    settings.topic_list_featured_images_tag = "featured";
    settings.topic_list_featured_images_view_type = "Camera roll";

    this.owner.unregister("service:store");
    this.owner.register("service:store", DeferredStore);
    this.store = this.owner.lookup("service:store");
    this.set("category", { id: 1 });
  });

  hooks.afterEach(function () {
    settings.topic_list_featured_images_category =
      this.originalSettings.categoryEnabled;
    settings.topic_list_featured_images_count = this.originalSettings.count;
    settings.topic_list_featured_images_filter_type =
      this.originalSettings.filterType;
    settings.topic_list_featured_images_from_current_category_only =
      this.originalSettings.restrictToCategory;
    settings.topic_list_featured_images_order = this.originalSettings.order;
    settings.topic_list_featured_images_source_show =
      this.originalSettings.showSource;
    settings.topic_list_featured_images_tag = this.originalSettings.source;
    settings.topic_list_featured_images_view_type =
      this.originalSettings.viewType;
  });

  test("ignores a previous category response that arrives last", async function (assert) {
    await render(
      <template><TlpFeaturedTopics @category={{this.category}} /></template>
    );
    await waitUntil(() => this.store.requests.length === 1);

    this.set("category", { id: 2 });
    await waitUntil(() => this.store.requests.length === 2);

    const [previousRequest, currentRequest] = this.store.requests;
    assert.strictEqual(
      previousRequest.request.params.category,
      "1",
      "the initial category is requested"
    );
    assert.strictEqual(
      currentRequest.request.params.category,
      "2",
      "the new category is requested"
    );

    currentRequest.resolve({ topics: [topic(2, "Current category topic")] });
    await waitUntil(() =>
      find(".tlp-featured-topic")?.textContent.includes(
        "Current category topic"
      )
    );

    previousRequest.resolve({ topics: [topic(1, "Previous category topic")] });
    await settled();

    assert
      .dom(".tlp-featured-topic")
      .hasText(
        /Current category topic/,
        "the current category remains visible"
      );
    assert
      .dom(".tlp-featured-topic")
      .doesNotIncludeText(
        "Previous category topic",
        "the stale response is ignored"
      );
  });
});
