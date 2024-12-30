from django.core.management.base import BaseCommand
import helpers
from django.conf import settings

STATICFILES_VENDOR_DIRS = getattr(settings, 'STATICFILES_VENDOR_DIRS')

VENDOR_STATICFILES = {
    'flowbite.min.css': "https://cdn.jsdelivr.net/npm/flowbite@2.5.2/dist/flowbite.min.css",
    'flowbite.min.js': "https://cdn.jsdelivr.net/npm/flowbite@2.5.2/dist/flowbite.min.js",
    'flowbite.min.js.map': "https://cdn.jsdelivr.net/npm/flowbite@2.5.2/dist/flowbite.min.js.map",
}

class Command(BaseCommand):
    def handle(self, *args, **options):
        self.stderr.write("Pulling vendor static files!")
        processed_urls = []
        for name, url in VENDOR_STATICFILES.items():
            output_path = STATICFILES_VENDOR_DIRS / name
            dl_success = helpers.download_to_local(url, output_path)
            if dl_success:
                processed_urls.append(url)
            else:
                self.stderr.write(self.style.WARNING("failed to download %s" % url))
                
        if set(processed_urls) == set(VENDOR_STATICFILES.values()):
            self.stdout.write(self.style.SUCCESS("Successfully downloaded all vendor static files!"))
            
        else:
            self.stderr.write(self.style.WARNING("Failed to download all vendor static files!"))