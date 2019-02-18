from setuptools import setup

# @todo Dependencies are missing.

setup(
    name='oldcarla_client',
    version='0.8.5',
    packages=['oldcarla', 'oldcarla.driving_benchmark', 'oldcarla.agent',
              'oldcarla.driving_benchmark.experiment_suites', 'oldcarla.planner'],
    license='MIT License',
    description='Python API for communicating with the 0.8 API of the CARLA server with LidarPlus extensions',
    url='https://github.com/carla-simulator/carla',
    author='The CARLA team',
    author_email='christopher.barber@analog.com',
    include_package_data=True
)
