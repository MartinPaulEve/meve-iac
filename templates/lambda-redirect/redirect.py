from uuid import UUID


def redirect(url):
    response = {
        'status': '302',
        'statusDescription': 'Found',
        'headers': {
            'location': [{
                'key': 'Location',
                'value': url
            }]
        }
    }

    return response


def is_valid_uuid(uuid_to_test, version=4):

    try:
        uuid_obj = UUID(uuid_to_test[-36:], version=version)
    except ValueError:
        return False
    return str(uuid_obj) == uuid_to_test


def lambda_handler(event, context):
    redirects = {
        'profile':
            'https://www.bbk.ac.uk/our-staff/profile/8727147/martin-paul-eve',
        'oahums':
            'https://www.cambridge.org/gb/academic/subjects/general/open-access-and-humanities-contexts-controversies-and-future?format=PB&isbn=9781107484016',
        'pynchonphil':
            'https://link.springer.com/book/10.1057/9781137405500',
        'password':
            'https://www.bloomsburycollections.com/book/password/'
    }

    domain = 'eve.gd'

    request = event['Records'][0]['cf']['request']
    headers = request['headers']

    host = headers['host'][0]['value']
    uri = request['uri']
    # this _should_ work, but for some reason the value isn't always there
    # scheme = headers['cloudfront-forwarded-proto'][0]['value']

    # handle URL redirects
    if len(uri) > 1:
        uri_plain = plain_uri(uri)

        final_path = uri_plain.split('/')[-1]

        if final_path.isnumeric():
            return request

        if is_valid_uuid(final_path):
            return request

        if uri_plain in redirects:
            return redirect(redirects[uri_plain])

    if host.startswith('books'):
        return redirect('https://{0}/books/'.format(domain))

    if host.startswith('www'):
        # this is a non-canonical site or non-HTTP
        return redirect('https://{0}{1}'.format(domain, uri))

    # redirect feed
    if uri.endswith('feed') or uri.endswith('feed/'):
        request['uri'] = '/feed.xml'

    # replace wp-content with images folder
    request['uri'].replace('wp-content', 'images')

    # handle subdirectories that have no index
    if uri.endswith('/'):
        request['uri'] = request['uri'] + 'index.html'
    elif '.' not in uri:
        if uri.startswith('/'):
            return redirect('https://{0}{1}/'.format(domain, uri))
        else:
            return redirect('https://{0}/{1}/'.format(domain, uri))

    return request


def plain_uri(uri):
    uri_plain = uri[1:] if uri.startswith('/') else uri
    uri_plain = uri_plain[:-1] if uri_plain.endswith('/') else uri_plain
    return uri_plain
