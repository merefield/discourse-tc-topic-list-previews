# frozen_string_literal: true

require_relative 'page_objects/components/fallback_masonry'

# This system spec covers theme behavior rather than a Ruby class.
# rubocop:disable RSpec/DescribeClass
RSpec.describe 'Topic List Previews fallback masonry' do
  fab!(:topic)
  fab!(:post) { Fabricate(:post, topic: topic) }

  let(:fallback_masonry) { PageObjects::Components::FallbackMasonry.new }

  before do
    upload_theme_component
    fallback_masonry.force_fallback
  end

  it 'updates a tile when an image finishes loading' do
    visit '/latest'
    fallback_masonry.wait_until_sized
    initial_span = fallback_masonry.row_span
    fallback_masonry.add_tall_image

    try_until_success { expect(fallback_masonry.row_span).to be > initial_span }
  end
end
# rubocop:enable RSpec/DescribeClass
