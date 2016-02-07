#ifndef MAIN_COMMON_CPP
#define MAIN_COMMON_CPP

#include <opencv2/core/core.hpp>

#include <iostream>
#include <iterator>

//----Shared elements
//------------------------------------------------------------

class CircuitElement
{

    public:
        CircuitElement()
            : id(0), NE(), SW(), val(0), type(0), node_id(2) {};

        CircuitElement(int _id, cv::Point _NE, cv::Point _SW, int _v, int _t)
            : id(_id), NE(_NE), SW(_SW), val(_v), type(_t), node_id(2) {};

        int id;
        cv::Point NE;
        cv::Point SW;
        int val;
        int type; // 0 is resistor
        std::vector<int> node_id;

        std::vector<int>::iterator node_id_begin() {return node_id.begin();}
        std::vector<int>::iterator node_id_end() {return node_id.end();}
};

class CircuitNode
{
    public:
        CircuitNode()
            : id(0), voltage(0), changeable(true), element_ids(), centroid() {};

        CircuitNode(int _id, double _v, std::vector<int> _elem, bool _c)
            : id(_id), voltage(_v), changeable(_c), element_ids(_elem), centroid() {};

        CircuitNode(int _id, std::vector<int> _elem, cv::Point _centroid)
            : id(_id), voltage(0), changeable(true), element_ids(_elem), centroid(_centroid) {};

        int id;
        double voltage;
        bool changeable;

        std::vector<int> element_ids;
        cv::Point centroid;

        // Some assembly required
        std::vector<int>::iterator elem_id_begin() {return element_ids.begin();}
        std::vector<int>::iterator elem_id_end() {return element_ids.end();}
};

inline std::ostream& operator<<(std::ostream& os, const CircuitNode& node) {
    os << "CircuitNode: id=" << node.id << " -> ";
    std::copy(node.element_ids.begin(), node.element_ids.end(), std::ostream_iterator<int>(os, ", "));
    os << ", V=" << node.voltage << ", changeable=" << node.changeable << ", centroid=" << node.centroid;
    return os;
}

#endif  /* MAIN_COMMON_CPP */
