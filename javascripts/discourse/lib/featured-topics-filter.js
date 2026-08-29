export function featuredTopicsRequest(filterType, parameter) {
  if (filterType === "category") {
    return { filter: "latest", params: { category: parameter } };
  }

  return { filter: `tag/${parameter}` };
}
