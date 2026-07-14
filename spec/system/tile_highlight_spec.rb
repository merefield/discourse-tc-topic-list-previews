# frozen_string_literal: true

RSpec.describe "Topic List Previews tile highlighting" do
  fab!(:topic)
  fab!(:post) { Fabricate(:post, topic: topic) }

  before { upload_theme_component }

  it "preserves the dominant-colour background while highlighting a tile" do
    visit "/latest"
    tile = find(".topic-list.tiles-style .topic-list-item")

    page.execute_script(<<~JS, tile)
        arguments[0].style.background = "rgb(12, 34, 56)";
        arguments[0].classList.add("highlighted");
      JS

    expect(page.evaluate_script("getComputedStyle(arguments[0]).backgroundColor", tile)).to eq(
      "rgb(12, 34, 56)",
    )
  end
end
