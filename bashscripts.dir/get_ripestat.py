#!/usr/bin/python
#Get ROUTING INFORMATION FROM STAT.RIPE.NET

import sys, re, urllib2, json, pygraphviz, os
from optparse import OptionParser
from datetime import datetime, timedelta
from url_error_handler import DefaultErrorHandler

outputf = None

RH_INCLUDE_FIRST_HOP    = 'true'

class RipeStatQuerier:
    "Perform HTTP request"
    
    @staticmethod
    def fetch_http(url):
        if url is None: return None
        
        content = None
        http_request = urllib2.Request(url)
        http_opener = urllib2.build_opener(DefaultErrorHandler())
        data = http_opener.open(http_request)
        if isinstance(data, urllib2.HTTPError):
            print "IP fetcher error, cannot open %s" % url
        else:
            try:
                content = json.loads(data.read())
            except:
                pass

        if content is None: return None
        content = content['data']

        return content
        
    @staticmethod
    def routing_history(resource, fromdate=None, todate=None):
        data = None
        if fromdate and todate:
            data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/routing-history/data.json?include_first_hop=%s&resource=%s&starttime=%s&endtime=%s" % (RH_INCLUDE_FIRST_HOP, resource, datetime.strftime(fromdate, "%Y-%m-%dT%H:%M:%S"), datetime.strftime(todate, "%Y-%m-%dT%H:%M:%S")))
        else:
            data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/routing-history/data.json?include_first_hop=%s&resource=%s" % (RH_INCLUDE_FIRST_HOP, resource,))
        if data is not None:
            for origin_prefixes in data['by_origin']:
                first_hop_as, origin_as = None, None
                first_hop_as_origin_as = origin_prefixes['origin'].split(' ')
                if len(first_hop_as_origin_as) == 1:
                    origin_as = first_hop_as_origin_as[0]
                else:
                    first_hop_as, origin_as = first_hop_as_origin_as
                for prefix_timelines in origin_prefixes['prefixes']:
                    prefix = prefix_timelines['prefix']
                    for starttime_endtime in prefix_timelines['timelines']:
                        if outputf: outputf.write("%s,%s,%s,%s,%s\n" % (first_hop_as, origin_as, prefix, starttime_endtime['starttime'].replace("T", " "), starttime_endtime['endtime'].replace("T", " ")))
                            
        return data
        
    @staticmethod
    def bgp_updates(resource, fromdate=None, todate=None):
        data = None
        if fromdate and todate:
            data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/bgp-updates/data.json?resource=%s&starttime=%s&endtime=%s" % (resource, datetime.strftime(fromdate, "%Y-%m-%dT%H:%M:%S"), datetime.strftime(todate, "%Y-%m-%dT%H:%M:%S")))
        else:
            data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/bgp-updates/data.json?resource=%s" % (resource,))
        if data is not None:
            if outputf: outputf.write("# of BGP UPDATES: %s\n" % (data['nr_updates'],))
            if outputf: outputf.write("RESOURCE: %s\n" % (data['resource'],))
            for update in data['updates']:
                if update['type'] == 'A':
                    if outputf: outputf.write("%s,%s,%s,%s,%s,RRC%s\n" % \
                        (update['type'], update['timestamp'].replace("T", " "), update['attrs']['target_prefix'], '>'.join(map(str, update['attrs']['path'])), ' '.join(update['attrs']['community']), update['attrs']['source_id']))
                elif update['type'] == 'W':
                    if outputf: outputf.write("%s,%s,%s,,,RRC%s\n" % \
                        (update['type'], update['timestamp'].replace("T", " "), update['attrs']['target_prefix'], update['attrs']['source_id']))
                        
        return data
        
    @staticmethod
    def plot_bgp_updates(resources, fromdate=None, todate=None, outputf=None):
        graph = pygraphviz.AGraph(strict=True, directed=True)
        for resource in resources:
            data = None
            if fromdate and todate:
                data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/bgp-updates/data.json?resource=%s&starttime=%s&endtime=%s" % (resource, datetime.strftime(fromdate, "%Y-%m-%dT%H:%M:%S"), datetime.strftime(todate, "%Y-%m-%dT%H:%M:%S")))
            else:
                data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/bgp-updates/data.json?resource=%s" % (resource,))
            if data is not None:
                for update in data['updates']:
                    if update['type'] == 'A':
                        i = len(update['attrs']['path']) - 1
                        while i > 1:
                            graph.add_node(update['attrs']['path'][i])
                            graph.add_node(update['attrs']['path'][i-1])
                            n_1 = graph.get_node(update['attrs']['path'][i])
                            n_2 = graph.get_node(update['attrs']['path'][i-1])
                            if i == len(update['attrs']['path']) - 1:
                                n_1.attr['style'] = 'filled'
                                n_1.attr['fillcolor'] = 'yellow'
                            graph.add_edge(n_1, n_2)
                            i -= 1
        if outputf is None:
            outputf = "bgp_updates_of_%s" % resources[0].replace("/", "")
        graph.write(outputf+".dot")
        graph.draw(outputf+".pdf", prog="dot")
                        
        return 0
        
    @staticmethod
    def bgp_state(resource, date=None):
        data = None
        if date:
            data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/bgp-state/data.json?resource=%s&timestamp=%s" % (resource, datetime.strftime(date, "%Y-%m-%dT%H:%M:%S")))
        else:
            data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/bgp-state/data.json?resource=%s" % (resource,))
        if data is not None:
            for state in data['bgp_state']:
                if outputf: outputf.write("%s,%s,RRC%s\n" % \
                    (state['target_prefix'], '>'.join(map(str, state['path'])), state['source_id']))
                        
        return data
                        
    @staticmethod
    def whois(resource):
        data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/whois/data.json?resource=%s" % (resource,))
        if data is not None:
            if outputf: outputf.write("RESOURCE:%s\n" % data['resource'])
            if outputf: outputf.write("AUTHORITATIVE:%s\n" % '-'.join(data['authorities']))
            if outputf: outputf.write("WHOIS RECORDS\n")
            for record in data['records']:
                for entry in record:
                    try:
                        if outputf: outputf.write("  %-15s: %s\n" % (entry['key'], entry['value']))
                    except:
                        if outputf: outputf.write("  %-15s: unicode decoding error!\n" % (entry['key'],))
            if outputf: outputf.write("IRR RECORDS\n")
            i = 1
            for record in data['irr_records']:
                if outputf: outputf.write("[%s]\n" % (i,))
                for entry in record:
                    try:
                        if outputf: outputf.write("  %-15s: %s\n" % (entry['key'], entry['value']))
                    except:
                        if outputf: outputf.write("  %-15s: unicode decoding error!\n" % (entry['key'],))
                i += 1
                    
        return data
        
    @staticmethod
    def allocation_history(resource, fromdate=None, todate=None):
        data = None
        if fromdate and todate:
            data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/allocation-history/data.json?resource=%s&starttime=%s&endtime=%s" % (resource, datetime.strftime(fromdate, "%Y-%m-%dT%H:%M:%S"), datetime.strftime(todate, "%Y-%m-%dT%H:%M:%S")))
        else:
            data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/allocation-history/data.json?resource=%s" % (resource,))
        if data is not None:
            for allocating_entity in data['results'].keys():
                for allocation in data['results'][allocating_entity]:
                    for timeline in allocation['timelines']:
                        if outputf: outputf.write("%s,%s,%s,%s\n" % \
                            (allocation['resource'], allocation['status'], timeline['starttime'].replace("T", " "), timeline['endtime'].replace("T", " ")))
                        
        return data
        
    @staticmethod
    def announced_prefixes(resource, fromdate=None, todate=None):
        data = None
        if fromdate and todate:
            data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/announced-prefixes/data.json?resource=%s&starttime=%s&endtime=%s" % (resource, datetime.strftime(fromdate, "%Y-%m-%dT%H:%M:%S"), datetime.strftime(todate, "%Y-%m-%dT%H:%M:%S")))
        else:
            data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/announced-prefixes/data.json?resource=%s" % (resource,))
        if data is not None:
            for prefix in data['prefixes']:
                for timeline in prefix['timelines']:
                    if outputf: outputf.write("%s,%s,%s\n" % \
                        (prefix['prefix'], timeline['starttime'].replace("T", " "), timeline['endtime'].replace("T", " ")))
                        
        return data
        
    @staticmethod
    def blacklist(resource, fromdate=None, todate=None):
        data = None
        if fromdate and todate:
            data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/blacklist/data.json?resource=%s&starttime=%s&endtime=%s" % (resource, datetime.strftime(fromdate, "%Y-%m-%dT%H:%M:%S"), datetime.strftime(todate, "%Y-%m-%dT%H:%M:%S")))
        else:
            data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/blacklist/data.json?resource=%s" % (resource,))
        if data is not None:
            for source in data['sources'].keys():
                for entry in data['sources'][source]:
                    for timeline in entry['timelines']:
                        if outputf: outputf.write("%s,%s,%s,%s,%s\n" % \
                            (source, entry['prefix'], entry['details'], timeline['starttime'].replace("T", " "), timeline['endtime'].replace("T", " ")))
                        
        return data
        
    @staticmethod
    def geolocation_history(resource, fromdate=None, todate=None):
        data = None
        if fromdate and todate:
            data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/geoloc-history/data.json?resource=%s&starttime=%s&endtime=%s" % (resource, datetime.strftime(fromdate, "%Y-%m-%dT%H:%M:%S"), datetime.strftime(todate, "%Y-%m-%dT%H:%M:%S")))
        else:
            data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/geoloc-history/data.json?resource=%s" % (resource,))
        if data is not None:
            for entry in data['months']:
                for distribution in entry['distributions']:
                    try:
                        if outputf: outputf.write("%s,%s,%s,%s\n" % \
                            (entry['month'].replace("T", " "), distribution['country'].encode('utf-8', 'ignore'), distribution['city'].encode('utf-8', 'ignore'), distribution['percentage']))
                    except:
                        if outputf: outputf.write("%s,,,%s\n" % \
                            (entry['month'].replace("T", " "), distribution['percentage']))
                        
        return data
        
    @staticmethod
    def looking_glass(resource):
        data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/looking-glass/data.json?resource=%s" % (resource,))
        if data is not None:
            if outputf: outputf.write("ROUTES FOR RRCS HAVING DATA FOR %s\n" % (data['resource'],))
            for rrc in data['rrcs'].keys():
                entries = data['rrcs'][rrc]['entries']
                location = data['rrcs'][rrc]['location']
                if outputf: outputf.write("%s@%s:\n" % (rrc, location))
                for entry in entries:
                    if outputf: outputf.write("\t%s\n" % (entry['as_path'],))
                    for detail in entry['details']:
                        if outputf: outputf.write("\t%s\n" % (detail))
            if outputf: outputf.write("THE FOLLOWING RRCS HAVE NO DATA FOR %s\n" % (data['resource'],))
            for rrc in data['no_data_rrcs']:
                if outputf: outputf.write("%s@%s\n" % (rrc['rrc'], rrc['location']))
                        
        return data
        
    @staticmethod
    def as_routing_consistency(resource):
        data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/as-routing-consistency/data.json?resource=%s" % (resource,))
        if data is not None:
            authority = data['authority']
            for export_t in data['exports']:
                if outputf: outputf.write("EXPORT,B=%s,W=%s,P=%s\n" % (export_t['in_bgp'], export_t['in_whois'], export_t['peer']))
            for import_t in data['imports']:
                if outputf: outputf.write("IMPORT,B=%s,W=%s,P=%s\n" % (import_t['in_bgp'], import_t['in_whois'], import_t['peer']))
            for prefix in data['prefixes']:
                if outputf: outputf.write("PREFIX,B=%s,W=%s,p=%s,irr=%s\n" % (prefix['in_bgp'], prefix['in_whois'], prefix['prefix'], ' '.join(prefix['irr_sources'])))
                        
        return data
        
    @staticmethod
    def prefix_routing_consistency(resource, fromdate=None, todate=None):
        data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/prefix-routing-consistency/data.json?resource=%s" % (resource,))
        if data is not None:
            for route in data['routes']:
                if outputf: outputf.write("%s,%s,%s,B=%s,W=%s,irr=%s\n" % (route['prefix'], route['origin'], route['asn_name'], route['in_bgp'], route['in_whois'], ' '.join(route['irr_sources'])))
                        
        return data
        
    @staticmethod
    def registry_browser(resource):
        data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/registry-browser/data.json?resource=%s" % (resource,))
        if data is not None:
            if 'objects' in data:
                if outputf: outputf.write("MATCHING OBJECTS\n")
                for object in data['objects']:
                    if outputf: outputf.write("%s:%s:%s\n" % (object['primary']['key'], object['primary']['value'], ' '.join(object['relationships'] if 'relationships' in object else '')))
                    for field in object['fields']:
                        if outputf: outputf.write("  %-15s: %-30s ==> %s\n" % (field['key'], field['value'], ' '.join(field['references'])))
            if 'backward_refs' in data:
                if outputf: outputf.write("REFERENCING OBJECTS\n")
                for backward_ref in data['backward_refs']:
                    if outputf: outputf.write("%s:%s:%s\n" % (backward_ref['primary']['key'], backward_ref['primary']['value'], ' '.join(backward_ref['relationships'] if 'relationships' in backward_ref else '')))
                    for field in backward_ref['fields']:
                        if outputf: outputf.write("  %-15s: %-30s ==> %s\n" % (field['key'], field['value'], ' '.join(field['references'])))
            if 'forward_refs' in data:
                if outputf: outputf.write("REFERENCED OBJECTS\n")
                for forward_ref in data['forward_refs']:
                    if outputf: outputf.write("%s:%s:%s\n" % (forward_ref['primary']['key'], forward_ref['primary']['value'], ' '.join(forward_ref['relationships'] if 'relationships' in forward_ref else '')))
                    for field in forward_ref['fields']:
                        if outputf: outputf.write("  %-15s: %-30s ==> %s\n" % (field['key'], field['value'], ' '.join(field['references'])))
            if 'suggestions' in data:
                if outputf: outputf.write("SUGGESTIONS (IN CASE OF NO OBJECT MATCH)\n")
                for suggestion in data['suggestions']:
                    if outputf: outputf.write("%s:%s:%s\n" % (suggestion['primary']['key'], suggestion['primary']['value'], ' '.join(suggestion['relationships'] if 'relationships' in suggestion else '')))
                    for field in suggestion['fields']:
                        if outputf: outputf.write("  %-15s: %-30s ==> %s\n" % (field['key'], field['value'], ' '.join(field['references'])))
                        
        return data
        
    @staticmethod
    def plot_registry_browser(resources, outputf=None):
        graph = pygraphviz.AGraph(strict=True, directed=False)
        resources_done = set()
            
        entity_types = {
            #'mntner'        : {
            #    'color' :   'blue',
            #    'refs'  : []
            #},
            'inetnum'       : {
                'color' : 'yellow',
                'refs'  : ['mntner', 'aut-num', 'route']
            },
            'aut-num'       : {
                'color' : 'green',
                'refs'  : ['mntner']
            },
            'route'         : {
                'color' : 'red',
                'refs'  : ['mntner', 'aut-num', 'inetnum']
            }
            #'organisation'  : 'purple',
            #'nic-hdl'       : 'lightblue',
            #'role'          : 'lightblue',
            #'person'        : 'lightblue',
        }
            
        resources = [resources]
        i = 0
        while i < len(resources):
            if i > 1: break
            new_resources = list()
            resources_t = resources[i]
            print resources_t
            for resource in resources_t:
                if "RIPE" in resource or "ARIN" in resource or "APNIC" in resource or "LACNIC" in resource or "AFRINIC" in resource:
                    continue
                data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/registry-browser/data.json?resource=%s" % (resource,))
                if data is not None:
                    record_types = None
                    if i == 0:
                        record_types = ['objects', 'backward_refs', 'forward_refs', 'suggestions']
                    else:
                        record_types = ['objects', 'suggestions']
                    for record_type in record_types:
                        last_n1 = None
                        for entity in data[record_type]:
                            if entity['primary']['key'] in entity_types.keys():
                                n_1 = entity['primary']['key']+":"+entity['primary']['value']
                                if i == 0 and record_type in ['objects', 'suggestions']:
                                    graph.add_node(n_1, style='filled', shape='rectangle', fillcolor=entity_types[n_1.split(":")[0]]['color'])
                                else:
                                    graph.add_node(n_1, style='filled', fillcolor=entity_types[n_1.split(":")[0]]['color'])
                                n_1 = graph.get_node(n_1)
                                for field in entity['fields']:
                                    n_2 = None
                                    #print field
                                    if len(field['references']) > 0 and field['references'][0] in entity_types.keys() and field['references'][0] in entity_types[n_1.split(":")[0]]['refs']:
                                        if 'person' in field['references'] or 'role' in field['references']:
                                            n_2 = "nic-hdl:"+field['value']
                                        else:
                                            n_2 = field['references'][0]+":"+field['value']
                                    if n_2 is not None:
                                        graph.add_node(n_2, style='filled', fillcolor=entity_types[n_2.split(":")[0]]['color'])
                                        n_2 = graph.get_node(n_2)
                                        graph.add_edge(n_2, n_1, color=entity_types[n_2.split(":")[0]]['color'])
                                        if n_2 not in resources_t and n_2 not in new_resources and n_2 not in resources_done:
                                            new_resources.append(n_2)
                                if last_n1 is not None:
                                    graph.add_edge(last_n1, n_1)
                                last_n1 = n_1
                resources_done.add(resource)
            resources.append(new_resources)
            i += 1
                        
        if outputf is None:
            outputf = "registry_browser_of_%s" % resources[0][0].replace("/", "").replace(":", "")
        graph.write(outputf+".dot")
        graph.draw(outputf+".pdf", prog="circo")
                        
        return 0
        
    @staticmethod
    def routing_status(resource, date=None):
        data = None
        if date:
            data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/routing-status/data.json?resource=%s&time=%s" % (resource, datetime.strftime(date, "%Y-%m-%dT%H:%M:%S")))
        else:
            data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/routing-status/data.json?resource=%s" % (resource,))
        if data is not None:
            if 'first_seen' in data and len(data['first_seen'].keys()) > 0:
                if outputf: outputf.write("FIRST SEEN PREFIX %s ANNOUNCED BY AS%s ON %s\n" % (data['first_seen']['prefix'], data['first_seen']['origin'], data['first_seen']['time'].replace("T", " ")))
            if 'last_seen' in data and len(data['last_seen'].keys()) > 0:
                if outputf: outputf.write("LAST SEEN PREFIX %s ANNOUNCED BY AS%s ON %s\n" % (data['last_seen']['prefix'], data['last_seen']['origin'], data['last_seen']['time'].replace("T", " ")))
            if 'less_specifics' in data and len(data['less_specifics']) > 0:
                if outputf: outputf.write("LESS SPECIFICS\n")
                for less_specific in data['less_specifics']:
                    if outputf: outputf.write("\tPREFIX %s ANNOUNCED BY AS%s\n" % (less_specific['prefix'], less_specific['origin']))
            if 'more_specifics' in data and len(data['more_specifics']) > 0:
                if outputf: outputf.write("MORE SPECIFICS\n")
                for less_specific in data['more_specifics']:
                    if outputf: outputf.write("\tPREFIX %s ANNOUNCED BY AS%s\n" % (more_specific['prefix'], more_specific['origin']))
            if 'origins' in data and len(data['origins']) > 0:
                if outputf: outputf.write("ORIGIN ASES\n")
                for origin in data['origins']:
                    if outputf: outputf.write("\tORIGIN AS%s SOURCE %s\n" % (origin['origin'], ' '.join(origin['route_objects'])))
            if 'observed_neighbours' in data:
                if outputf: outputf.write("OBSERVED NEIGHBOURS\n")
                if outputf: outputf.write("\t%s\n" % (data['observed_neighbours'],))
            if 'announced_space' in data and len(data['announced_space']) > 0:
                if outputf: outputf.write("ANNOUNCED SPACE\n")
                if outputf: outputf.write("\tIPv4: %s PREFIX(ES) FOR A TOTAL OF %s IPs\n" % (data['announced_space']['v4']['prefixes'], data['announced_space']['v4']['ips']))
                if outputf: outputf.write("\tIPv6: %s PREFIX(ES) FOR A TOTAL OF %s /48s\n" % (data['announced_space']['v6']['prefixes'], data['announced_space']['v6']['48s']))
            if outputf: outputf.write("VISIBILITY\n")
            if outputf: outputf.write("\tIPv4:%s/%s PEERS (%s%%)\n" % (data['visibility']['v4']['ris_peers_seeing'], data['visibility']['v4']['total_ris_peers'], float(data['visibility']['v4']['ris_peers_seeing'])/float(data['visibility']['v4']['total_ris_peers'])*100))
            if outputf: outputf.write("\tIPv6:%s/%s PEERS (%s%%)\n" % (data['visibility']['v6']['ris_peers_seeing'], data['visibility']['v6']['total_ris_peers'], float(data['visibility']['v6']['ris_peers_seeing'])/float(data['visibility']['v4']['total_ris_peers'])*100))
                        
        return data
        
    @staticmethod
    def whois_object_last_updated(resource, type, source):
        data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/whois-object-last-updated/data.json?object=%s&type=%s&source=%s" % (resource, type, source))
        if data is not None:
            if outputf: outputf.write("OBJECT      : %s\n" % (data['object']))
            if outputf: outputf.write("LAST UPDATED: %s\n" % (data['last_updated'].replace("T", " ") if data['last_updated'] is not None else 'unknown'))
            if outputf: outputf.write("SAME AS LIVE: %s\n" % (data['same_as_live']))
                        
        return data
        
    @staticmethod
    def address_space_hierarchy(resource):
        data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/address-space-hierarchy/data.json?aggr_levels_below=64&get_org_names=true&resource=%s" % (resource,))
        if data is not None:
            for record_type in ['exact', 'less_specific', 'more_specific']:
                i = 1
                if outputf: outputf.write("%s MATCHES\n" % (record_type.upper()))
                for record in data[record_type]:
                    if outputf: outputf.write("[%s]\n" % (i,))
                    for k in record.keys():
                        record[k] = record[k].replace("\n", " ")
                        try:
                            if k == 'org':
                                if outputf: outputf.write("  %-15s: %s - %s\n" % (k, record[k], data['org_names'][record[k]]))
                            else:
                                if outputf: outputf.write("  %-15s: %s\n" % (k, record[k]))
                        except:
                            if outputf: outputf.write("  %-15s: unicode decoding error!\n" % (k,))
                    i += 1
                        
        return data
        
    @staticmethod
    def dns_chain(resource):
        data = RipeStatQuerier.fetch_http("https://stat.ripe.net/data/dns-chain/data.json?resource=%s" % (resource,))
        if data is not None:
            if 'forward_nodes' in data:
                for domain in data['forward_nodes'].keys():
                    if outputf: outputf.write("DNS records:%s->%s\n" % (domain, ','.join(data['forward_nodes'][domain])))
            if 'reverse_nodes' in data:
                for ip in data['reverse_nodes'].keys():
                    if outputf: outputf.write("Reverse DNS records:%s->%s\n" % (ip, ','.join(data['reverse_nodes'][ip])))
            if 'authoritative_nameservers' in data:
                if outputf: outputf.write("Authoritative nameservers:%s\n" % (','.join(data['authoritative_nameservers'],)))
            if 'nameservers' in data:
                if outputf: outputf.write("Nameservers IP address:%s\n" % (','.join(data['nameservers'],)))
                        
        return data
        
    @staticmethod
    def team_cymru_ip2asn(resource):
        """
        Attempt to find the Autonomous system number of the given IP address using
        Team-Cymru service
        """
    
        if resource is None:
            return None
    
        reverse_ip = ".".join(reversed(resource.strip().split(".")))
        str_origin_asn = reverse_ip + ".origin.asn.cymru.com"
        #str_peer_asn = reverse_ip + ".peer.asn.cymru.com"

        # ASN info, eg: " {ASN} | {ip block} | {cc} | {registry} | {date allocated} "
        # Example: "26780 | 208.72.168.0/21 | US | arin | 2006-11-17"
        answer_origin = os.popen("dig +short " + str_origin_asn + " txt").readline()
        answer_origin = answer_origin.lstrip("\"")
        answer_origin = answer_origin.rstrip("\"\n")
        answer_origin = answer_origin.split(" | ")
        
        asn = answer_origin[0] if len(answer_origin) > 0 else 0
        prefix = answer_origin[1] if len(answer_origin) > 1 else '0.0.0.0/0'
        cc = answer_origin[2] if len(answer_origin) > 2 else 'ZZ'
        registry = answer_origin[3] if len(answer_origin) > 3 else None
        date_alloc = answer_origin[4] if len(answer_origin) > 4 else None
        
        if outputf: outputf.write("%s,%s,%s,%s\n" % (resource, prefix, asn, cc))
    
        #print ip
        #print answer_origin
    
        # Peer info, eg: " {Peer AS's} | {ip block} | {cc} | {registry} | {date allocated} "
        # Example: "174 1273 3257 3356 3549 10310 20965 | 193.190.0.0/15 | BE | ripencc | 1993-09-01"
        #answer_peer = os.popen("dig +short " + str_peer_asn + " txt").readline()
        #answer_peer = answer_peer.lstrip("\"")
        #answer_peer = answer_peer.rstrip("\"\n")
            
        return answer_origin
        
def str2datetime(str):
    dt = str
    error = False
    try:
        dt = datetime.strptime(str, "%Y-%m-%d %H:%M:%S")
    except:
        error = True
    if error:
        try:
            dt = datetime.strptime(str, "%Y-%m-%d %H:%M:%S.%f")
        except:
            error = True
    if error:
        try:
            dt = datetime.strptime(str, "%Y-%m-%d")
        except:
            error = True
    
    return dt
     
def open_read_file(file):
    return __open_file(file, "r")

def open_write_file(file):
    return __open_file(file, "w")
    
def open_writa_file(file):
    return __open_file(file, "a")

def __open_file(file, mode):
    if file is None or mode is None: return None
    
    f = None
    try:
        if file.endswith(".gz"):
            # Uncompress and read GZIP file
            f = gzip.open(file, "%sb" % mode)
        else:
            # Read non-compressed file
            f = open(file, mode)
    except:
        raise Exception("cannot open file '%s'" % (file))
    
    return f

def quit(code, msg=None):
    if msg: print msg
    exit(code)

if __name__ == '__main__':
    parser = OptionParser()
    parser.add_option("--bgp-updates", action="store_true", dest="bgp_updates", default=None, help="Query BGP Updates ASN/PREFIX")
    parser.add_option("--bgp-state", action="store_true", dest="bgp_state", default=None, help="Query BGP State ASN/PREFIX")
    parser.add_option("--plot-bgp-updates", action="store_true", dest="plot_bgp_updates", default=None, help="Plot BGP Updates ASN/PREFIX")
    parser.add_option("--routing-history", action="store_true", dest="routing_history", default=None, help="Query Routing History ASN/PREFIX")
    parser.add_option("--whois", action="store_true", dest="whois", default=None, help="Query WHOIS ASN/PREFIX")
    parser.add_option("--allocation-history", action="store_true", dest="allocation_history", default=None, help="Query Allocation History ASN/PREFIX")
    parser.add_option("--announced-prefixes", action="store_true", dest="announced_prefixes", default=None, help="Query Announced Prefixes ASN")
    parser.add_option("--blacklist", action="store_true", dest="blacklist", default=None, help="Query Backlist ASN/PREFIX")
    parser.add_option("--geolocation-history", action="store_true", dest="geolocation_history", default=None, help="Query Geolocation ASN/PREFIX")
    parser.add_option("--looking-glass", action="store_true", dest="looking_glass", default=None, help="Query Looking Glass ASN/PREFIX")
    parser.add_option("--as-routing-consistency", action="store_true", dest="as_routing_consistency", default=None, help="Query AS Routing Consistency ASN")
    parser.add_option("--prefix-routing-consistency", action="store_true", dest="prefix_routing_consistency", default=None, help="Query Prefix Routing Consistency PREFIX")
    parser.add_option("--registry-browser", action="store_true", dest="registry_browser", default=None, help="Query Registry Browser ASN/PREFIX/OTHER OBJECT")
    parser.add_option("--plot-registry-browser", action="store_true", dest="plot_registry_browser", default=None, help="Plot Registry Browser ASN/PREFIX/OTHER OBJECT")
    parser.add_option("--routing-status", action="store_true", dest="routing_status", default=None, help="Query Routing Status ASN/PREFIX")
    parser.add_option("--whois-object-last-updated", action="store_true", dest="whois_object_last_updated", default=None, help="Query WHOIS Object Last Updated ASN/PREFIX/OTHER OBJECT")
    parser.add_option("--address-space-hierarchy", action="store_true", dest="address_space_hierarchy", default=None, help="Query Address Space Hierarchy PREFIX")
    parser.add_option("--dns-chain", action="store_true", dest="dns_chain", default=None, help="Query DNS Chain HOSTNAME/IP ADDRESS")
    parser.add_option("--tc-ip2asn", action="store_true", dest="team_cymru_ip2asn", default=None, help="Query Team Cumry IP2AS mapping")
    parser.add_option("--fromdate", "-f", action="store", dest="fromdate", default=None, help="Start date&time")
    parser.add_option("--todate", "-t", action="store", dest="todate", default=None, help="End date&time")
    parser.add_option("--inputf", "-i", action="store_true", dest="inputf", default=None, help="Input comes from file")
    parser.add_option("--outputf", "-o", action="store", dest="outputf", default=None, help="Output to file")
    parser.add_option("--iparse", action="store_true", dest="iparse", default=False, help="Parse input")
    parser.add_option("--delimiter", action="store", dest="delimiter", default=",", help="Delimiter used to parse input")
    
    (options,args) = parser.parse_args()
    
    fromdate, todate = None, None
    if options.fromdate:
        fromdate = str2datetime(options.fromdate)
    if options.todate:
        todate = str2datetime(options.todate)
    
    resources = None
    if len(args) > 0:
        if options.inputf:
            resources = map(lambda x: x.rstrip("\n"), open_read_file(args[0]).readlines())
        else:
            try:
                resources = map(lambda x: "AS%d" % int(x), args)
            except:
                resources = args
        
    outputf = None
    if options.outputf is None:
        outputf = sys.stdout
    else:
        outputf = open_write_file(options.outputf)
        
    if resources is not None:
        if not fromdate:
            todate = None
        if fromdate and not todate:
            todate = datetime.now()
        if options.plot_registry_browser:
            RipeStatQuerier.plot_registry_browser(resources, options.outputf)
        elif options.plot_bgp_updates:
            RipeStatQuerier.plot_bgp_updates(resources, fromdate=fromdate, todate=todate, outputf=options.outputf)
        else:
            for resource in resources:
                if options.iparse:
                    resource_t = resource.split(options.delimiter)
                    if len(resource_t) < 3: continue
                    resource = resource_t[int(args[1])]
                    #fromdate = str2datetime(resource_t[int(options.fromdate)])-timedelta(hours=8)
                    #todate = str2datetime(resource_t[int(options.todate)])+timedelta(hours=8)
                    fromdate = str2datetime(resource_t[int(options.todate)])+timedelta(days=1)
                if outputf: outputf.write("--------------------------------------------------------------------------------\n")
                if outputf: outputf.write("|%s|\n" % (resource.center(78, " ")))
                if outputf: outputf.write("--------------------------------------------------------------------------------\n")
                if options.bgp_updates:
                    RipeStatQuerier.bgp_updates(resource, fromdate=fromdate, todate=todate)
                if options.bgp_state:
                    RipeStatQuerier.bgp_state(resource, date=fromdate)
                elif options.routing_history:
                    RipeStatQuerier.routing_history(resource, fromdate=fromdate, todate=todate)
                elif options.whois:
                    RipeStatQuerier.whois(resource)
                elif options.allocation_history:
                    RipeStatQuerier.allocation_history(resource, fromdate=fromdate, todate=todate)
                elif options.announced_prefixes:
                    RipeStatQuerier.announced_prefixes(resource, fromdate=fromdate, todate=todate)
                elif options.blacklist:
                    RipeStatQuerier.blacklist(resource, fromdate=fromdate, todate=todate)
                elif options.geolocation_history:
                    RipeStatQuerier.geolocation_history(resource, fromdate=fromdate, todate=todate)
                elif options.looking_glass:
                    RipeStatQuerier.looking_glass(resource)
                elif options.as_routing_consistency:
                    RipeStatQuerier.as_routing_consistency(resource)
                elif options.prefix_routing_consistency:
                    RipeStatQuerier.prefix_routing_consistency(resource)
                elif options.registry_browser:
                    RipeStatQuerier.registry_browser(resource)
                elif options.routing_status:
                    RipeStatQuerier.routing_status(resource, date=fromdate)
                elif options.whois_object_last_updated:
                    if len(args) > 2:
                        RipeStatQuerier.whois_object_last_updated(resource, type=args[1], source=args[2])
                elif options.address_space_hierarchy:
                    RipeStatQuerier.address_space_hierarchy(resource)
                elif options.dns_chain:
                    RipeStatQuerier.dns_chain(resource)
                elif options.team_cymru_ip2asn:
                    RipeStatQuerier.team_cymru_ip2asn(resource)
                
    outputf.close()
    
    quit(0)
