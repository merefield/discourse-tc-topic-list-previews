export function carouselCountForWidth({ gap, maximum, minimumWidth, width }) {
  if (width <= 0) {
    return maximum;
  }

  return Math.min(
    maximum,
    Math.max(1, Math.floor((width + gap) / (minimumWidth + gap)))
  );
}
