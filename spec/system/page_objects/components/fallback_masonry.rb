# frozen_string_literal: true

module PageObjects
  module Components
    # Drives the fallback topic-list masonry layout in a real browser.
    class FallbackMasonry < Base
      ITEM_SELECTOR = ".topic-list.tiles-style .topic-list-item"

      FORCE_FALLBACK_SCRIPT = <<~JS
        const nativeSupports = CSS.supports.bind(CSS);

        CSS.supports = (...args) => {
          if (args[0] === "display: grid-lanes") {
            return false;
          }

          return nativeSupports(...args);
        };
      JS

      ADD_TALL_IMAGE_SCRIPT = <<~JS
        const style = document.createElement("style");
        style.textContent = `
          .topic-list.tiles-style tbody {
            display: grid !important;
            grid-auto-rows: 4px !important;
          }
        `;
        document.head.append(style);

        const image = document.createElement("img");
        image.alt = "";
        image.id = "fallback-masonry-tall-image";
        document.querySelector(".topic-list.tiles-style .topic-list-item").append(image);
        image.src =
          "data:image/svg+xml," +
          encodeURIComponent(`
            <svg xmlns="http://www.w3.org/2000/svg"
                 width="100" height="1000" viewBox="0 0 100 1000">
              <rect width="100" height="1000" fill="red" />
            </svg>
          `);
      JS

      def force_fallback
        page.driver.with_playwright_page do |playwright_page|
          playwright_page.add_init_script(script: FORCE_FALLBACK_SCRIPT)
        end
      end

      def wait_until_sized
        find("#{ITEM_SELECTOR}[style*='grid-row-end']")
      end

      def row_span
        page.evaluate_script(<<~JS)
          Number.parseInt(
            document.querySelector("#{ITEM_SELECTOR}").style.gridRowEnd.split(" ").at(-1),
            10
          )
        JS
      end

      def add_tall_image
        page.execute_script(ADD_TALL_IMAGE_SCRIPT)
        find("#fallback-masonry-tall-image")
      end
    end
  end
end
