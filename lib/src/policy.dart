
class Policy {
  final int maxRedirects;
  final bool followRedirects;

  const Policy({
    this.maxRedirects = 5,
    this.followRedirects = true,
  });
}