import pathlib
from django.shortcuts import render
from django.http import HttpResponse
from django.conf import settings
from visits.models import PageVisit

def home_page_view(request, *args, **kwargs):
    queryset = PageVisit.objects.filter(path=request.path)
    page_visits_count = PageVisit.objects.all().count()
    title = 'My Home Page'
    context = {
        'page_title': title,
        'page_visits_count': page_visits_count
    }
    path = request.path
    print('path', path)
    visits = PageVisit.objects.create(path=path)
    return render(request, 'home.html', context)