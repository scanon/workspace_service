############################################################
#
# Autogenerated by the KBase type compiler -
# any changes made here will be overwritten
#
# Passes on URLError, timeout, and BadStatusLine exceptions.
#     See: 
#     http://docs.python.org/2/library/urllib2.html
#     http://docs.python.org/2/library/httplib.html
#
############################################################

try:
    import json
except ImportError:
    import sys
    sys.path.append('simplejson-2.3.3')
    import simplejson as json
    
import urllib2, httplib
from urllib2 import URLError

class ServerError(Exception):

    def __init__(self, name, code, message):
        self.name = name
        self.code = code
        self.message = message

    def __str__(self):
        return self.name + ': ' + str(self.code) + '. ' + self.message

class workspaceService:

    def __init__(self, url, timeout = 30 * 60):
        if url != None:
            self.url = url
        self.timeout = int(timeout)
        if self.timeout < 1:
            raise ValueError('Timeout value must be at least 1 second')

    def load_media_from_bio(self, params):

        arg_hash = { 'method': 'workspaceService.load_media_from_bio',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def import_bio(self, params):

        arg_hash = { 'method': 'workspaceService.import_bio',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def import_map(self, params):

        arg_hash = { 'method': 'workspaceService.import_map',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def save_object(self, params):

        arg_hash = { 'method': 'workspaceService.save_object',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def delete_object(self, params):

        arg_hash = { 'method': 'workspaceService.delete_object',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def delete_object_permanently(self, params):

        arg_hash = { 'method': 'workspaceService.delete_object_permanently',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def get_object(self, params):

        arg_hash = { 'method': 'workspaceService.get_object',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def get_object_by_ref(self, params):

        arg_hash = { 'method': 'workspaceService.get_object_by_ref',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def save_object_by_ref(self, params):

        arg_hash = { 'method': 'workspaceService.save_object_by_ref',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def get_objectmeta(self, params):

        arg_hash = { 'method': 'workspaceService.get_objectmeta',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def get_objectmeta_by_ref(self, params):

        arg_hash = { 'method': 'workspaceService.get_objectmeta_by_ref',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def revert_object(self, params):

        arg_hash = { 'method': 'workspaceService.revert_object',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def copy_object(self, params):

        arg_hash = { 'method': 'workspaceService.copy_object',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def move_object(self, params):

        arg_hash = { 'method': 'workspaceService.move_object',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def has_object(self, params):

        arg_hash = { 'method': 'workspaceService.has_object',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def object_history(self, params):

        arg_hash = { 'method': 'workspaceService.object_history',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def create_workspace(self, params):

        arg_hash = { 'method': 'workspaceService.create_workspace',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def get_workspacemeta(self, params):

        arg_hash = { 'method': 'workspaceService.get_workspacemeta',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def get_workspacepermissions(self, params):

        arg_hash = { 'method': 'workspaceService.get_workspacepermissions',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def delete_workspace(self, params):

        arg_hash = { 'method': 'workspaceService.delete_workspace',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def clone_workspace(self, params):

        arg_hash = { 'method': 'workspaceService.clone_workspace',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def list_workspaces(self, params):

        arg_hash = { 'method': 'workspaceService.list_workspaces',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def list_workspace_objects(self, params):

        arg_hash = { 'method': 'workspaceService.list_workspace_objects',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def set_global_workspace_permissions(self, params):

        arg_hash = { 'method': 'workspaceService.set_global_workspace_permissions',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def set_workspace_permissions(self, params):

        arg_hash = { 'method': 'workspaceService.set_workspace_permissions',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def get_user_settings(self, params):

        arg_hash = { 'method': 'workspaceService.get_user_settings',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def set_user_settings(self, params):

        arg_hash = { 'method': 'workspaceService.set_user_settings',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def queue_job(self, params):

        arg_hash = { 'method': 'workspaceService.queue_job',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def set_job_status(self, params):

        arg_hash = { 'method': 'workspaceService.set_job_status',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def get_jobs(self, params):

        arg_hash = { 'method': 'workspaceService.get_jobs',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def get_types(self, ):

        arg_hash = { 'method': 'workspaceService.get_types',
                     'params': [],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def add_type(self, params):

        arg_hash = { 'method': 'workspaceService.add_type',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def remove_type(self, params):

        arg_hash = { 'method': 'workspaceService.remove_type',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')

    def patch(self, params):

        arg_hash = { 'method': 'workspaceService.patch',
                     'params': [params],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        ret = urllib2.urlopen(self.url, body, timeout = self.timeout)
        if ret.code != httplib.OK:
            raise URLError('Received bad response code from server:' + ret.code)
        resp = json.loads(ret.read())

        if 'result' in resp:
            return resp['result'][0]
        elif 'error' in resp:
            raise ServerError(**resp['error'])
        else:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')




        
