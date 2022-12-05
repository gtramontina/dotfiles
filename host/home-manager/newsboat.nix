{ config, pkgs, ... }:
{

  programs = {
    newsboat = {
      enable = true;
      autoReload = true;
      reloadTime = 10;
      urls = [
        { url = "https://gtramontina.com/feed.atom"; title = "Guilherme Tramontina"; }
        { url = "https://8thlight.com/blog/feed/rss.xml"; title = "8th Light"; }
        { url = "https://feed.infoq.com/"; title = "InfoQ"; }
        { url = "https://blog.ploeh.dk/rss.xml"; title = "Mark Seemann (ploeh)"; }
        { url = "http://feeds.hanselman.com/ScottHanselman"; title = "Scott Hanselman"; }
        { url = "http://blog.cleancoder.com/atom.xml"; title = "The Clean Code Blog"; }
        { url = "https://twobithistory.org/feed.xml"; title = "Two-Bit History"; }
        { url = "http://steve-yegge.blogspot.com/atom.xml"; title = "Steve Yegge"; }
        { url = "https://news.ycombinator.com/rss"; title = "Hacker News"; }
        { url = "https://lobste.rs/rss"; title = "Lobste.rs"; }
        { url = "https://enterprisecraftsmanship.com/index.xml"; title = "Enterprise Craftsmanship"; }
        { url = "https://codeopinion.com/feed/"; title = "Code Opinion"; }
        { url = "https://atthis.link/rss.xml"; title = "At This (Mark)"; }
        { url = "https://brandur.org/articles.atom"; title = "Brandur.org (Articles)"; }
        { url = "https://brandur.org/fragments.atom"; title = "Brandur.org (Fragments)"; }
        { url = "https://goodbyeworld.dev/feed.xml"; title = "Goodbye World (endtimes.dev)"; }
        { url = "https://bartoszmilewski.com/feed/"; title = "Bartosz Milewski"; }
        { url = "https://www.joelonsoftware.com/feed/"; title = "Joel on Software"; }
        { url = "https://martinfowler.com/feed.atom"; title = "Martin Fowler"; }
        { url = "https://www.davefarley.net/?feed=rss2"; title = "Dave Farley"; }
        { url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCCfqyGl3nq_V0bo64CjZh8g"; title = "YT: Continuous Delivery (Dave Farley)";  tags = ["youtube"]; }
        { url = "https://spotifeed.timdorr.com/4rOoJ6Egrf8K2IrywzwOMk"; title = "SP: The Joe Rogan Experience"; }
      ];
    };
  };

}
