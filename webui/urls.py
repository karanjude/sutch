from django.conf.urls.defaults import *
from django.conf import settings

# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()

urlpatterns = patterns('',
    # Example:
    # (r'^desksearch/', include('webui.foo.urls')),
      	(r'^$', 'webui.frontend.views.indextwitter'),
      	(r'^twitter$', 'webui.frontend.views.twitter'),
      	(r'^facebook$', 'webui.frontend.views.facebook'),
      	(r'^sutch/$', 'webui.frontend.views.sutch'),
        (r'^do/$', 'webui.frontend.views.do'),
        (r'^done/$', 'webui.frontend.views.done'),
        (r'^plugins/start$', 'webui.frontend.views.start_plugin'),
        (r'^plugins/stop$', 'webui.frontend.views.stop_plugin'),
	(r'^launch/$', 'webui.frontend.views.launch'), 
	(r'^most_recent/$', 'webui.frontend.views.most_recent'), 
	(r'^autocomplete/$', 'webui.frontend.views.autocomplete'), 
	(r'^reset_autocomplete/$','webui.frontend.views.reset_auto_complete'),
	(r'^most_clicked/$', 'webui.frontend.views.most_clicked'), 
      	(r'^query/q/$', 'webui.frontend.views.query'), 
	(r'^query/q/next/(?P<next_count>\d+)/(?P<meta_data>.*)$', 'webui.frontend.views.next_result'),
	(r'^query/q/back/(?P<back_count>\d+)/(?P<meta_data>.*)$', 'webui.frontend.views.back_result'),
	(r'^static_media/(?P<path>.*)$','django.views.static.serve',{'document_root': settings.MEDIA_ROOT}),
	(r'^images/(?P<path>.*)$', 'webui.frontend.views.images'),

    # Uncomment the admin/doc line below and add 'django.contrib.admindocs' 
    # to INSTALLED_APPS to enable admin documentation:
    # (r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    # (r'^admin/(.*)', admin.site.root),
)
