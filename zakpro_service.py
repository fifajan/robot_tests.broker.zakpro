# -*- coding: utf-8 -*-
from datetime import timedelta, datetime
from random import choice, seed
import time

LETTERS = ['A', 'B', 'C', 'D', 'E', 'F']
NUMBERS = list(range(1000))

PROTOCOL = 'https://'
DOMAIN = 'market.zakupkipro.com'

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



def procuringEntity_name_zakpro(INITIAL_TENDER_DATA):
    INITIAL_TENDER_DATA.data.procuringEntity['name'] = u'ТОВ "Прозорі Люди"'
    return INITIAL_TENDER_DATA


def convert_prom_string_to_common_string(string):
    return {
        u"Украина": u"Україна",
        u"Киевская область": u"м. Київ",
        u"килограммы": u"кілограм",
    }.get(string, string)
