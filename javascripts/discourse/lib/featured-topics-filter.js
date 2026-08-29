export function featuredTopicsRequest(filterType, parameter) {
  if (filterType === "category") {
    return { filter: "latest", params: { category: parameter } };
  }

  return { filter: `tag/${parameter}` };
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
