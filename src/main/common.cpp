#include <main/common.hpp>

#include <boost/python.hpp>

BOOST_PYTHON_MODULE(common)
{
    using namespace boost::python;

    class_<CircuitElement>("CircuitElement")
        .def_readwrite("id", &CircuitElement::id)
        .def_readwrite("val", &CircuitElement::val)
        .def_readwrite("is_resistor", &CircuitElement::type)
        .def("node_ids", range(&CircuitElement::node_id_begin, &CircuitElement::node_id_end));

    class_<CircuitNode>("CircuitNode")
        .def_readwrite("id", &CircuitNode::id)
        .def_readwrite("voltage", &CircuitNode::voltage)
        .def_readwrite("changeable", &CircuitNode::changeable)
        .def("element_ids", range(&CircuitNode::elem_id_begin, &CircuitNode::elem_id_end));
}
