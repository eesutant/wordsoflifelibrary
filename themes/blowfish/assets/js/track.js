window.ma = window.ma || function () { (ma.q = ma.q || []).push(arguments) }
ma('create', '{{ site.Params.google.analytics.id }}')
ma('send', 'pageview')