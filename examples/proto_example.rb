require 'stepladder'

stepladder do
  repeatedly do
    twitter_api.get_tweets
  end
  worker :tweet_parser do |response|
    tweets_in(response).each do |tweet|
      handoff tweet
    end
  end
  filter do |tweet|
    is_not_from_me? tweet
  end
  worker do |tweet|
    format tweet
  end
  # new kind of worker...but wait a minute...
  # how do we know how many tweets to collect?
  collector :tweet_parser do |tweets|
    render_layout_with tweets
  end
end
