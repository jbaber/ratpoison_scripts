#!/usr/bin/python
import feedparser, time, os, pyosd, urllib2
#########################################
# Name: RatRSSd Version 0.2		#
# Author: Michael Sheldon		#
# URL: http://www.mikeasoft.com		#
# License: GPL				#
#########################################

#################
# CONFIGURATION #
#################

feeds = [	"http://slashdot.org/index.rss",
		"http://theregister.co.uk/excerpts.rss",
		"http://enrager.net/newswire/backend/weblog.rss",
		"http://www.guardian.co.uk/rssfeed/0,15065,1,00.xml"
	]

#proxy = "http://wwwcache.aber.ac.uk:8080"
proxy = None
encoding = "ISO-8859-1"
colour = "yellow"
# How many items to show per feed (0 for all)
limit = 5
shadow_colour = "black"
shadow_offset = 2
outline_colour = "black"
outline_offset = 1
# Seconds before changing items
timeout = 10
# Font strings can be generated easily with xfontsel
font = "-*-bitstream vera sans-bold-r-*-*-14-*-*-*-*-*-*-*"
# Valid alignment values are pysod.ALIGN_RIGHT, pyosd.ALIGN_LEFT and pyosd.ALIGN_CENTER
align = pyosd.ALIGN_RIGHT
# Valid vertical position values are pysod.POS_TOP, pyosd.POS_MID and pyosd.POS_BOT
vertical_pos = pyosd.POS_BOT 

#####################
# END CONFIGURATION #
#####################


osd = pyosd.osd()
osd.set_align(align)
osd.set_pos(vertical_pos)
osd.set_colour(colour)
osd.set_shadow_colour(shadow_colour)
osd.set_shadow_offset(shadow_offset)
osd.set_outline_colour(outline_colour)
osd.set_outline_offset(outline_offset)
osd.set_timeout(timeout)
osd.set_font(font)
osd.display("RatRSSd by Michael Sheldon (http://www.mikeasoft.com)")
time.sleep(timeout)
if proxy:
	proxy_handler = urllib2.ProxyHandler({"http": proxy})
	urlopener = urllib2.build_opener(proxy_handler)
	urllib2.install_opener(urlopener)

while 1:
	for feed in feeds:
		feedurl = urllib2.urlopen(feed)
		news = feedparser.parse(feedurl)
		for item in news.entries:
			try:
				title = news['feed']['title']
				story = item.title
				osd.display(title + ": " + story)
			except:
				osd.display("Couldn't display item.")
			time.sleep(timeout)	
