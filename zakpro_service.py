# -*- coding: utf-8 -*-
from datetime import datetime, timedelta
from random import choice, seed
from urllib2 import urlopen
import time

LETTERS = ['A', 'B', 'C', 'D', 'E', 'F']
NUMBERS = list(range(1000))

PROTOCOL = 'http://'
DOMAIN = 'market.zakupkipro.com'
PORT = '8080'

seconds = int(time.time())
seed(seconds)


def strip_zakpro(string):
    return string.strip()


def get_all_zakpro_dates(period_interval=31):
    now = datetime.now()
    return {
        'EndPeriod': (now + timedelta(minutes=8)).strftime("%d.%m.%Y %H:%M"),
        'StartDate': (now + timedelta(minutes=8)).strftime("%d.%m.%Y %H:%M"),
        'EndDate': (now + timedelta(minutes=(8 + period_interval))).strftime("%d.%m.%Y %H:%M"),
    }

def conv_dates_zakpro(str_date):
    splitted = str_date.split(' ')
    start = ' '.join([splitted[1][:-1], splitted[2]])
    end = ' '.join([splitted[-2][:-1], splitted[-1]])
    return [start, end]

def get_text_zakpro(tender_info, field):
    #tender = eval(tender_info)
    return tender_info

def trigger_search_sync_zakpro():
    # sync_url = 'https://market.zakupkipro.com/sync_es_stuff'
    sync_url = '%s%s:%s/sync_es_stuff' % (PROTOCOL, DOMAIN, PORT)
    resp = urlopen(sync_url)
    return '__SYNC_TRIGGERED__'


def get_random_id_zakpro():
    int_1 = choice(NUMBERS)
    int_2 = choice(NUMBERS)
    char_1 = choice(LETTERS)
    char_2 = choice(LETTERS)
    return 'ZKP_TEST_%s%s%s%s' % (int_1, char_1, int_2, char_2)


def get_tender_url_zakpro(homepage, tender_id):
    return homepage + '/tenders/' + tender_id


def convert_date_to_zakpro_tender(isodate):
    first_iso = datetime.strptime(isodate, "%d.%m.%y").isoformat()
    return first_iso


def convert_date_to_zakpro_tender_startdate(isodate):
    first_date = isodate.split(' - ')[0]
    first_iso = datetime.strptime(first_date, "%d.%m.%y %H:%M").isoformat()
    return first_iso


def convert_date_to_zakpro_tender_enddate(isodate):
    second_date = isodate.split(' - ')[1]
    second_iso = datetime.strptime(second_date, "%d.%m.%y %H:%M").isoformat()
    return second_iso


def adapt_zakpro_data(tender_data):
    tender_data.data.procuringEntity['name'] = u'ТОВ "Прозорі Люди"'
    tender_data.data['value']['valueAddedTaxIncluded'] = False
#    tender_data.data['minimalStep'] = int(tender_data.data['minimalStep'])
    return tender_data

def convert_string_from_dict_zakpro(string):
    return {
#        u"м. Київ": u"Київська область",
#        u"Київська область": u"м. Київ",
#        u"кг": u"кілограм",
        u"грн": u"UAH",
        u"(з ПДВ)": u"True",
        u"(без ПДВ)": u"false",
#        u"Картонні коробки": u"Картонки",
        u"ДК": u"ДКПП",
        u"Відкриті торги": u"aboveThresholdUA",
    }.get(string, string)

def convert_zakpro_string_to_common_string(string):
    return {
        u"Украина": u"Україна",
        u"Киевская область": u"м. Київ",
        u"килограммы": u"кілограм",
    }.get(string, string)
