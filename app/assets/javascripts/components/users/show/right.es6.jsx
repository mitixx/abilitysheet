class UserProfileRight extends React.Component {
  shouldComponentUpdate(nextProps, nextState) { return CheckComponentUpdate(this.props, nextProps, this.state, nextState) }

  render() {
    return (
      <div className='uk-width-7-10'>
        <CalHeatmap user={this.props.user} viewport={this.props.viewport} />
        <SplineGraph initialRender={false} iidxid={this.props.user.iidxid} />
      </div>
    )
  }
}

UserProfileRight.proptypes = {
  user: React.PropTypes.object.isRequired,
  viewport: React.PropTypes.bool.isRequired
}