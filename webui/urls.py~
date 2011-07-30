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
        (r'^facebook/do/$', 'webui.frontend.views.do'),
        (r'^done/$', 'webui.frontend.views.done'),
      	(r'^query/q/$', 'webui.frontend.views.query'), 
	(r'^static_media/(?P<path>.*)$','django.views.static.serve',{'document_root': settings.MEDIA_ROOT}),
	(r'^images/(?P<path>.*)$', 'webui.frontend.views.images'),

    # Uncomment the admin/doc line below and add 'django.contrib.admindocs' 
    # to INSTALLED_APPS to enable admin documentation:
    # (r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    # (r'^admin/(.*)', admin.site.root),
)
