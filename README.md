# spaceflight
## Scraping Wikipedia for spaceflight history data

Wikipedia has some pretty good historical data on space launches.

I scrapped those pages, processed them to a usable form, and now you can play with the data:

~~~sh
git clone git@github.com:radex/spaceflight.git
cd spaceflight
./play
~~~

This launches a Ruby REPL. You can use standard Ruby syntax to query that data.

#### Examples

This shows you a random launch:

~~~ruby
data.sample
~~~

Countries by number of launches:

~~~rb
data.group_by { |l| l.rocket.country.first }.map { |k, v| [k, v.count] }.sort_by { |k, v| v }.reverse
~~~

Most popular rocket models:

~~~ruby
data.group_by { |l| l.rocket.name }.map { |k, v| [k, v.count] }.sort_by { |k, v| v }.reverse
~~~

Most commonly used launch sites:

~~~ruby
data.group_by { |l| l.launch_site.name.split.reject {|w| w =~ /\d/ || w =~ /site/i || w =~ /LC/ }.join(' ') }.map { |k, v| [k, v.count] }.sort_by { |k, v| v }.reverse
~~~

Most common orbits:

~~~ruby
data.reject { |l| l.payloads.empty? }. group_by { |l| l.payloads.first.orbit }.map { |k, v| [k, v.count] }.sort_by { |k, v| v }.reverse
~~~

#### Disclaimer

There are some major holes in the Wikipedia data. For example, many years in the 70s only have a few launches listed, suborbital spaceflight data is completely missing for many years, and there are a few years with no data at all.
