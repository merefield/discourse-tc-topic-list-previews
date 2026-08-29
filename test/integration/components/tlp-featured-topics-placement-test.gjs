import { clearRender, render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import TlpFeaturedTopicsPlacement from "../../../discourse/components/tlp-featured-topics-placement";

module(
  "Integration | Component | TlpFeaturedTopicsPlacement",
  function (hooks) {
    setupRenderingTest(hooks);

    hooks.beforeEach(function () {
      this.originalPlacement = settings.topic_list_featured_images_placement;
    });

    hooks.afterEach(function () {
      settings.topic_list_featured_images_placement = this.originalPlacement;
    });

    test("renders featured topics in only the configured outlet", async function (assert) {
      settings.topic_list_featured_images_placement = "Above topic list";

      await render(
        <template>
          <div class="test-above-topic-list">
            <TlpFeaturedTopicsPlacement @placement="Above topic list" />
          </div>
          <div class="test-above-navigation">
            <TlpFeaturedTopicsPlacement
              @placement="Above navigation controls"
            />
          </div>
        </template>
      );

      assert.dom(".test-above-topic-list .tlp-featured-topics").exists();
      assert.dom(".test-above-navigation .tlp-featured-topics").doesNotExist();

      await clearRender();
      settings.topic_list_featured_images_placement =
        "Above navigation controls";

      await render(
        <template>
          <div class="test-above-topic-list">
            <TlpFeaturedTopicsPlacement @placement="Above topic list" />
          </div>
          <div class="test-above-navigation">
            <TlpFeaturedTopicsPlacement
              @placement="Above navigation controls"
            />
          </div>
        </template>
      );

      assert.dom(".test-above-topic-list .tlp-featured-topics").doesNotExist();
      assert.dom(".test-above-navigation .tlp-featured-topics").exists();
    });
  }
);
