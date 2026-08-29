import { module, test } from "qunit";
import { carouselCountForWidth } from "../../../discourse/lib/featured-carousel-layout";

module("Unit | Lib | featured-carousel-layout", function () {
  test("uses the configured count as a responsive maximum", function (assert) {
    const options = { gap: 12, maximum: 4, minimumWidth: 250 };

    assert.strictEqual(
      carouselCountForWidth({ ...options, width: 1100 }),
      4,
      "a wide carousel uses the configured maximum"
    );
    assert.strictEqual(
      carouselCountForWidth({ ...options, width: 800 }),
      3,
      "the carousel drops a column before images become too narrow"
    );
    assert.strictEqual(
      carouselCountForWidth({ ...options, width: 500 }),
      1,
      "at least one image remains visible"
    );
  });
});
