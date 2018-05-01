#include <FilterFactory.h>
#include <BasicVideoFilterBGRA.h>
#include <GrayscaleVideoFilter.h>
#include <InvertColorsVideoFilter.h>
#include <SepiaVideoFilter.h>
#include <FisheyeVideoFilter.h>

namespace videocore {
    std::map<std::string, InstantiateFilter>* FilterFactory::s_registration = nullptr ;
    
    FilterFactory::FilterFactory() {
        {
            filters::BasicVideoFilterBGRA b;
            filters::GrayscaleVideoFilter g;
            filters::InvertColorsVideoFilter i;
            filters::SepiaVideoFilter s;
            filters::FisheyeVideoFilter f;
        }
    }
    IFilter*
    FilterFactory::filter(std::string name) {
        IFilter* filter = nullptr;
        
        auto it = m_filters.find(name) ;
        if( it != m_filters.end() ) {
            filter = it->second.get();
        } else if (FilterFactory::s_registration != nullptr) {
            auto iit = FilterFactory::s_registration->find(name);
            
            if(iit != FilterFactory::s_registration->end()) {
                m_filters[name].reset(iit->second());
                filter = m_filters[name].get();
            }
        }
        
        return filter;
    }
    
    void
    FilterFactory::_register(std::string name, InstantiateFilter instantiation)
    {
        if(!s_registration) {
            s_registration = new std::map<std::string, InstantiateFilter>();
        }
        s_registration->emplace(std::make_pair(name, instantiation));
    }
}