const MAX_TOPIC_LIST_PAGE_SIZE = 30;
const FEATURED_TOPIC_BUFFER_MULTIPLIER = 2;

export function featuredTopicsPageSize(count) {
  const normalizedCount = Math.max(0, Math.floor(Number(count) || 0));

  if (normalizedCount === 0) {
    return;
  }

  return Math.min(
    MAX_TOPIC_LIST_PAGE_SIZE,
    normalizedCount * FEATURED_TOPIC_BUFFER_MULTIPLIER
  );
}

export function featuredTopicsRequest(
  filterType,
  parameter,
  {
    count = 0,
    currentCategory,
    featuredCategory,
    order = "latest",
    restrictToCurrentCategory = false,
  } = {}
) {
  const params = {};
  let requestCategory = featuredCategory;

  if (restrictToCurrentCategory && currentCategory) {
    if (
      filterType === "category" &&
      !categoryContainsTopic(featuredCategory, currentCategory)
    ) {
      return;
    }

    requestCategory = currentCategory;
    params.no_subcategories = true;
  }

  if (filterType === "category") {
    params.category = String(requestCategory?.id ?? parameter);
  } else if (requestCategory) {
    params.category = String(requestCategory.id);
  }

  const perPage = featuredTopicsPageSize(count);
  if (perPage) {
    params.per_page = perPage;
  }

  if (order === "created") {
    params.order = "created";
  }

  const request = {
    filter: filterType === "category" ? "latest" : `tag/${parameter}`,
  };

  if (Object.keys(params).length > 0) {
    request.params = params;
  }

  return request;
}

export function categoryContainsTopic(featuredCategory, topicCategory) {
  if (!featuredCategory || !topicCategory) {
    return false;
  }

  return (
    topicCategory.id === featuredCategory.id ||
    topicCategory.ancestors?.some(
      (category) => category.id === featuredCategory.id
    ) === true
  );
}
