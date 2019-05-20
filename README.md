# Sustainable Development Goal 9.1.1
## Proportion of the rural population who live within 2 km of an all-season road.

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

## World Bank SDG 9.1.1 Metadata: 
**Definition:**
The indicator (commonly known as the Rural Access Index or RAI) measures the share of a country’s rural
population that lives within 2 km of an all-season road.
**Rationale:**
Among other factors, transport connectivity is an essential part of the enabling environment for inclusive
and sustained growth. In developing countries, particularly in Africa, the vast majority of agricultural
production remains smallholder farming with limited access to local, regional, or global markets. Isolated
manufacturing and other local businesses (except for those related to mining) often lag behind in the
global market. Limited transport connectivity is also a critical constraint to accessing social and
administrative services, especially in rural areas where the majority of the poor live.
Rural access is key to unleashing untapped economic potential and eradicating poverty in many
developing countries. In the short term, transport costs and travel time can be reduced by improved road
conditions. Over the longer term, agricultural productivity will be increased, and firms will become more
profitable with the creation of more jobs, eventually helping to alleviate poverty. 

Full metadata: https://unstats.un.org/sdgs/metadata/files/Metadata-09-01-01.pdf

## Data
Before running the script download the following data sets and place them in the specified folders.

**GRIP roads:**
 * https://www.globio.info/download-grip-dataset 
 * Download the fgdb file for the relevant region
 * Unzip into the data/roads folder in your working directory
 
**GHS Population Grid and Settlement Grid:**
 * http://cidportal.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_POP_GPW4_GLOBE_R2015A/GHS_POP_GPW42015_GLOBE_R2015A_54009_1k/V1-0/GHS_POP_GPW42015_GLOBE_R2015A_54009_1k_v1_0.zip
 * http://cidportal.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_SMOD_POP_GLOBE_R2016A/GHS_SMOD_POP2015_GLOBE_R2016A_54009_1k/V1-0/GHS_SMOD_POP2015_GLOBE_R2016A_54009_1k_v1_0.zip
 * Unzip both into data/raster folder in your working directory

## Authors / Contributors
ONS Geography Research

## Sources
**Global Roads Inventory Project**
 * Meijer, J.R., Huijbegts, M.A.J., Schotten, C.G.J. and Schipper, A.M. (2018): Global patterns of current and future road infrastructure. Environmental Research Letters, 13-064006. Data is available at www.globio.info

**GHS Population Grid**
 * European Commission, Joint Research Centre (JRC); Columbia University, Center for International Earth Science Information Network - CIESIN (2015):  GHS population grid, derived from GPW4, multitemporal (1975, 1990, 2000, 2015). European Commission, Joint Research Centre (JRC) [Dataset] PID: http://data.europa.eu/89h/jrc-ghsl-ghs_pop_gpw4_globe_r2015a
 
**GHS Settlement Grid**
 * Pesaresi, Martino; Freire, Sergio (2016):  GHS Settlement grid following the REGIO model 2014 in application to GHSL Landsat and CIESIN GPW v4-multitemporal (1975-1990-2000-2015). European Commission, Joint Research Centre (JRC) [Dataset] PID: http://data.europa.eu/89h/jrc-ghsl-ghs_smod_pop_globe_r2016a
